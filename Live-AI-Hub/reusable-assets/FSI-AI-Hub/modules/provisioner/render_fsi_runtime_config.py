#!/usr/bin/env python3
"""Render Terraform-supplied FSI configuration into a private SQL*Plus script."""
from __future__ import annotations

import hashlib
import json
import os
import re
import sys
from pathlib import Path

KEY_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_$#]{0,127}$")
SECRET_RE = re.compile(
    r"(^|_)(TOKEN|PASSWORD|PASSWD|API_KEY|SECRET|PRIVATE_KEY|CLIENT_SECRET|"
    r"CONNECTION_STRING|ACCESS_KEY|SIGNING_KEY|AUTHORIZATION)(_|$)|(_URI)$|(^|_)GOOGLE_SHEET_(URL|GID)$",
    re.IGNORECASE,
)


def env_json(name: str) -> dict[str, str]:
    raw = os.environ.get(name, "{}")
    value = json.loads(raw)
    if not isinstance(value, dict):
        raise ValueError(f"{name} must be a JSON object")
    result: dict[str, str] = {}
    for key, item in value.items():
        if not isinstance(key, str) or not KEY_RE.fullmatch(key):
            raise ValueError(f"{name} contains an invalid configuration key")
        if not isinstance(item, str):
            raise ValueError(f"{name} values must be strings")
        result[key.upper()] = item
    return result


def sql_string(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def clob_expr(value: str) -> str:
    if not value:
        return "to_clob('')"
    # 400 Unicode code points stays below Oracle's 4,000-byte SQL literal limit
    # even when every character is a four-byte code point and every apostrophe doubles.
    parts = [value[i : i + 400] for i in range(0, len(value), 400)]
    return " ||\n      ".join(f"to_clob({sql_string(part)})" for part in parts)


def secret_flag(key: str) -> str:
    return "Y" if SECRET_RE.search(key) else "N"


def category(key: str) -> str:
    if key.startswith("OCI_") or "_PROFILE" in key or "_MODEL" in key:
        return "AI"
    if any(token in key for token in ("TOKEN", "PASSWORD", "API_KEY", "_URI", "_URL", "DATABRICKS", "GOOGLE", "AZURE")):
        return "INTEGRATION"
    return "GENERAL"


def external_databricks_catalog_sql(runtime: dict[str, str]) -> list[str]:
    """Provision the external Databricks Unity Iceberg catalog used by FSI."""
    required_keys = (
        "AZURE_BLOB_USERNAME",
        "AZURE_BLOB_PASSWORD",
        "DATABRICKS_CLIENT_ID",
        "DATABRICKS_CLIENT_SECRET",
        "DATABRICKS_OAUTH_TOKEN_ENDPOINT",
        "DATABRICKS_CATALOG_ENDPOINT",
        "DATABRICKS_CATALOG",
        "DATABRICKS_SCHEMA",
        "DATABRICKS_REPAIRER_FRAUD_TABLE",
        "AZURE_BLOB_CREDENTIAL_NAME",
        "DATABRICKS_OAUTH_CREDENTIAL_NAME",
        "DATABRICKS_ICEBERG_CATALOG_NAME",
    )
    missing = [key for key in required_keys if not runtime.get(key, "").strip()]
    if missing:
        raise ValueError("Missing external Databricks settings: " + ", ".join(missing))

    from urllib.parse import urlsplit

    for key in ("DATABRICKS_OAUTH_TOKEN_ENDPOINT", "DATABRICKS_CATALOG_ENDPOINT"):
        parsed = urlsplit(runtime[key].strip())
        if parsed.scheme.lower() != "https" or not parsed.hostname or parsed.username or parsed.password:
            raise ValueError(f"{key} must be an HTTPS URL without embedded credentials")

    def safe_identifier(key: str) -> str:
        value = runtime[key].strip().upper()
        if not re.fullmatch(r"[A-Z][A-Z0-9_$#]{0,127}", value):
            raise ValueError(f"{key} must be a simple Oracle identifier")
        return value

    storage_credential = safe_identifier("AZURE_BLOB_CREDENTIAL_NAME")
    oauth_credential = safe_identifier("DATABRICKS_OAUTH_CREDENTIAL_NAME")
    catalog_name = safe_identifier("DATABRICKS_ICEBERG_CATALOG_NAME")
    schema_name = safe_identifier("DATABRICKS_SCHEMA")
    table_name = safe_identifier("DATABRICKS_REPAIRER_FRAUD_TABLE")
    if not re.fullmatch(r"[a-z0-9]{3,24}", runtime["AZURE_BLOB_USERNAME"].strip()):
        raise ValueError("AZURE_BLOB_USERNAME must be an Azure storage account name")

    lines = [
        "declare",
        "  l_storage_username varchar2(4000);",
        "  l_storage_password varchar2(4000);",
        "  l_client_id varchar2(4000);",
        "  l_client_secret varchar2(4000);",
        "  l_token_endpoint varchar2(4000);",
        "  l_catalog_endpoint varchar2(4000);",
        "  l_test_result number;",
        "  l_sql varchar2(4000);",
        "  function config_value(p_key varchar2) return varchar2 is",
        "    l_value varchar2(4000);",
        "  begin",
        "    select dbms_lob.substr(config_value, 4000, 1)",
        "      into l_value from fsi_runtime_config where config_key = upper(p_key);",
        "    return l_value;",
        "  end;",
        "begin",
        "  l_storage_username := config_value('AZURE_BLOB_USERNAME');",
        "  l_storage_password := config_value('AZURE_BLOB_PASSWORD');",
        "  l_client_id := config_value('DATABRICKS_CLIENT_ID');",
        "  l_client_secret := config_value('DATABRICKS_CLIENT_SECRET');",
        "  l_token_endpoint := config_value('DATABRICKS_OAUTH_TOKEN_ENDPOINT');",
        "  l_catalog_endpoint := config_value('DATABRICKS_CATALOG_ENDPOINT');",
        f"  begin dbms_catalog.unmount(catalog_name => '{catalog_name}'); exception when others then null; end;",
        f"  begin dbms_cloud_admin.drop_database_link(db_link_name => '{catalog_name}'); exception when others then null; end;",
        f"  begin dbms_cloud.drop_credential(credential_name => '{storage_credential}'); exception when others then null; end;",
        f"  begin dbms_cloud.drop_credential(credential_name => '{oauth_credential}'); exception when others then null; end;",
        "  dbms_cloud.create_credential(",
        f"    credential_name => '{storage_credential}',",
        "    username => l_storage_username,",
        "    password => l_storage_password",
        "  );",
        "  dbms_share.create_bearer_token_credential(",
        f"    credential_name => '{oauth_credential}',",
        "    token_endpoint => l_token_endpoint,",
        "    client_id => l_client_id,",
        "    client_secret => l_client_secret,",
        "    token_scope => 'all-apis',",
        "    grant_type => 'client_credentials'",
        "  );",
        "  dbms_catalog.mount_iceberg(",
        f"    catalog_name => '{catalog_name}',",
        "    endpoint => l_catalog_endpoint,",
        f"    catalog_credential => '{oauth_credential}',",
        f"    data_storage_credential => '{storage_credential}',",
        "    enabled => true,",
        "    catalog_type => 'ICEBERG_UNITY'",
        "  );",
        f"  dbms_catalog.flush_catalog_cache('{catalog_name}');",
        f"  dbms_catalog.prefill_catalog_cache('{catalog_name}', '{schema_name}');",
        f"  l_sql := 'select 1 from {schema_name}.{table_name}@{catalog_name} where rownum = 1';",
        "  begin",
        "    execute immediate l_sql into l_test_result;",
        "    dbms_output.put_line('External Databricks Unity catalog and table read succeeded.');",
        "  exception",
        "    when no_data_found then",
        "      dbms_output.put_line('External Databricks Unity catalog connected; configured table currently has no rows.');",
        "  end;",
        "end;",
        "/",
        f"prompt External Databricks Unity catalog {catalog_name} provisioned.",
        "prompt Verify the requested external Databricks table query",
        f"select * from {schema_name}.{table_name}@{catalog_name};",
        "",
    ]
    return lines


def render() -> str:
    runtime = env_json("FSI_RUNTIME_CONFIG_JSON")
    apex = env_json("FSI_APEX_CONFIG_JSON")
    allowed_apex_keys = {
        "AI_SERVICE_STATIC_ID", "FRAUD_TEAM", "GENERIC_TEAM", "LLM_MODEL_ID", "RAG_TEAM"
    }
    if set(apex) != allowed_apex_keys:
        raise ValueError("FSI_APEX_CONFIG_JSON must contain the five supported APEX keys")

    instructions = os.environ.get("FSI_APEX_LLM_INSTRUCTIONS", "")
    enabled = os.environ.get("FSI_ENABLE_NEW_CLAIM_INVESTIGATION", "false").lower()
    if enabled not in {"true", "false"}:
        raise ValueError("FSI_ENABLE_NEW_CLAIM_INVESTIGATION must be true or false")
    accept_claims = "Y" if enabled == "true" else "N"
    digest = hashlib.sha256(instructions.encode("utf-8")).hexdigest()

    lines = [
        "set define off verify off feedback on serveroutput on",
        "prompt Verify the Oracle APEX database session",
        "select sysdate from dual;",
        "whenever oserror exit 9",
        "whenever sqlerror exit sql.sqlcode rollback",
        "declare",
        "  procedure upsert_runtime(p_key varchar2, p_value clob, p_secret char, p_category varchar2) is",
        "  begin",
        "    merge into fsi_runtime_config d",
        "    using (select upper(p_key) config_key from dual) s",
        "       on (d.config_key = s.config_key)",
        "    when matched then update set",
        "      d.config_value = coalesce(p_value, d.config_value), d.is_secret = p_secret,",
        "      d.config_category = p_category, d.updated_at = systimestamp, d.updated_by = user",
        "    when not matched then insert (config_key, config_value, config_category, is_secret, updated_by)",
        "      values (upper(p_key), p_value, p_category, p_secret, user);",
        "  end;",
        "begin",
    ]
    for key, value in sorted(runtime.items()):
        lines.extend(
            [
                f"  upsert_runtime({sql_string(key)},",
                f"      {clob_expr(value)}, {sql_string(secret_flag(key))}, {sql_string(category(key))});",
            ]
        )

    lines.extend(
        [
            "  delete from fsi_runtime_config where config_key in (",
            "    'DATABRICKS_TOKEN', 'DATABRICKS_URL', 'DATABRICKS_HTTP_PATH',",
            "    'DATABRICKS_WAREHOUSE_ID', 'DATABRICKS_SQL'",
            "  );",
            "",
        ]
    )

    for key, value in sorted(apex.items()):
        lines.extend(
            [
                "  merge into crossshield_apex_config d",
                f"  using (select {sql_string(key)} config_key, {sql_string(value)} config_value from dual) s",
                "     on (d.config_key = s.config_key)",
                "  when matched then update set d.config_value = s.config_value, d.is_secret = 'N', d.updated_at = systimestamp",
                "  when not matched then insert (config_key, config_value, is_secret) values (s.config_key, s.config_value, 'N');",
            ]
        )

    lines.extend(
        [
            "  merge into fsi_apex_llm_config d",
            "  using (select 'FRAUD_REPORT_SYSTEM_INSTRUCTIONS' config_key from dual) s",
            "     on (d.config_key = s.config_key)",
            "  when matched then update set",
            f"    d.config_value = {clob_expr(instructions)},",
            "    d.profile_name = 'FSI_FRAUD_INVESTIGATION_AGENT',",
            "    d.source_file = 'Terraform variable fsi_apex_llm_instructions',",
            f"    d.source_sha256 = '{digest}', d.updated_at = systimestamp",
            "  when not matched then insert (config_key, config_value, profile_name, source_file, source_sha256)",
            f"    values ('FRAUD_REPORT_SYSTEM_INSTRUCTIONS', {clob_expr(instructions)}, 'FSI_FRAUD_INVESTIGATION_AGENT', 'Terraform variable fsi_apex_llm_instructions', '{digest}');",
            "",
            "  merge into fsi_scheduler_control d",
            "  using (select 'FSI_INVESTIGATE_NEW_JOB' job_name from dual) s",
            "     on (d.job_name = s.job_name)",
            f"  when matched then update set d.accept_new_claims = '{accept_claims}', d.changed_at = systimestamp, d.changed_by = user",
            f"  when not matched then insert (job_name, accept_new_claims, changed_by) values ('FSI_INVESTIGATE_NEW_JOB', '{accept_claims}', user);",
            "end;",
            "/",
            "commit;",
            "prompt FSI Terraform configuration applied.",
            "",
        ]
    )
    lines.extend(external_databricks_catalog_sql(runtime))
    return "\n".join(lines)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: render_fsi_runtime_config.py OUTPUT.sql", file=sys.stderr)
        return 2
    output = Path(sys.argv[1])
    content = render()
    output.parent.mkdir(parents=True, exist_ok=True)
    fd = os.open(output, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as stream:
        stream.write(content)
    os.chmod(output, 0o600)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, json.JSONDecodeError) as exc:
        print(f"Unable to render FSI configuration ({type(exc).__name__}); check the supplied runtime configuration.", file=sys.stderr)
        raise SystemExit(1)
