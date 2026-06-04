import json
import os
import sys

from pymongo import MongoClient
import oracledb


def require_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def main() -> int:
    mongo_uri = require_env("MONGO_URI")
    mongo_dbname = require_env("MONGO_DBNAME")

    oracle_user = require_env("ORACLE_USER")
    oracle_password = require_env("ORACLE_PASSWORD")
    oracle_dsn = require_env("ORACLE_DSN")
    oracle_wallet = require_env("ORACLE_WALLET_LOCATION")

    os.environ["TNS_ADMIN"] = oracle_wallet

    try:
        oracledb.init_oracle_client(
            lib_dir="/usr/lib/oracle/21/client64/lib",
            config_dir=oracle_wallet
        )
    except Exception:
        pass

    conn = oracledb.connect(
        user=oracle_user,
        password=oracle_password,
        dsn=oracle_dsn,
        config_dir=oracle_wallet
    )
    cur = conn.cursor()

    mongo = MongoClient(
        mongo_uri,
        serverSelectionTimeoutMS=10000,
        connectTimeoutMS=10000,
        retryWrites=False
    )

    db = mongo[mongo_dbname]
    profiles = db["customer_profile"]

    merge_profile_sql = """
    merge into customer_profile_oracle t
    using (
        select :customer_id as customer_id,
               :email as email,
               :full_name as full_name,
               :profile_json as profile_json
        from dual
    ) s
    on (t.customer_id = s.customer_id)
    when matched then update set
        t.email = s.email,
        t.full_name = s.full_name,
        t.profile_json = s.profile_json,
        t.updated_at = current_timestamp
    when not matched then insert (
        customer_id, email, full_name, profile_json
    ) values (
        s.customer_id, s.email, s.full_name, s.profile_json
    )
    """

    merge_app_user_sql = """
    merge into app_users t
    using (
        select :email as email,
               :full_name as full_name,
               :password as password,
               :customer_id as customer_id,
               :is_active as is_active
        from dual
    ) s
    on (lower(t.email) = lower(s.email))
    when matched then update set
        t.full_name = s.full_name,
        t.password = s.password,
        t.customer_id = s.customer_id,
        t.is_active = s.is_active,
        t.updated_at = current_timestamp
    when not matched then insert (
        email, full_name, password, customer_id, is_active
    ) values (
        s.email, s.full_name, s.password, s.customer_id, s.is_active
    )
    """

    synced = 0

    for doc in profiles.find({}):
        customer_id = doc.get("customerId")
        personal = doc.get("personalInfo", {}) or {}
        email = personal.get("email")
        full_name = personal.get("fullName")

        if customer_id is None or not email:
            continue

        profile_json = json.dumps(doc, ensure_ascii=False, default=str)

        cur.execute(
            merge_profile_sql,
            {
                "customer_id": customer_id,
                "email": email,
                "full_name": full_name,
                "profile_json": profile_json,
            },
        )

        cur.execute(
            merge_app_user_sql,
            {
                "email": email,
                "full_name": full_name or email,
                "password": "user",
                "customer_id": customer_id,
                "is_active": "Y",
            },
        )

        synced += 1

    cur.execute(
        merge_app_user_sql,
        {
            "email": "demo",
            "full_name": "Demo User",
            "password": "demo",
            "customer_id": 1,
            "is_active": "Y",
        },
    )

    conn.commit()

    cur.execute("select count(*) from customer_profile_oracle")
    profile_count = cur.fetchone()[0]

    cur.execute("select count(*) from app_users")
    app_users_count = cur.fetchone()[0]

    print("customer_profile_oracle count =", profile_count)
    print("app_users count =", app_users_count)
    print("synced profiles =", synced)

    cur.close()
    conn.close()
    mongo.close()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise