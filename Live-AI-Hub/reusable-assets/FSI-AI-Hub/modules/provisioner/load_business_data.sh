#!/usr/bin/env bash
set -eo pipefail
wallet_zip_path="$1"
conn_db="$2"
schema_name="$3"
script_dir="$(cd "$(dirname "$0")" && pwd)"
sequence_sync_file="$script_dir/sync_application_sequences.sql"
if ! printenv FSI_DB_PASSWORD >/dev/null || ! printenv FSI_APPLICATION_DATA_PAR_URL >/dev/null; then
  echo "Required FSI database password or application-data PAR is missing." >&2
  exit 2
fi
data_file="$(mktemp -t fsi-sample-data.XXXXXX)"
chmod 600 "$data_file"
trap 'rm -f "$data_file"' EXIT
echo "[FSI] Downloading FSI_files/01_fsi_application_data.sql to $data_file"
echo "[FSI] Sequence sync SQL file: $sequence_sync_file"
python3 - "$data_file" <<'PYTHON'
import os, sys, urllib.parse, urllib.request
url=os.environ.get("FSI_APPLICATION_DATA_PAR_URL","")
parts=urllib.parse.urlsplit(url)
host="objectstorage.us-ashburn-1.oraclecloud.com"
if parts.scheme!="https" or parts.hostname!=host or "/p/" not in parts.path or "/o/" not in parts.path or not parts.path.endswith("/FSI_files/01_fsi_application_data.sql"):
    raise SystemExit("Configured application-data PAR URL is invalid.")
try:
    req=urllib.request.Request(url,headers={"User-Agent":"FSI-Terraform-Provisioner/1.0"})
    with urllib.request.urlopen(req,timeout=300) as response:
        final=urllib.parse.urlsplit(response.geturl())
        if final.scheme!="https" or final.hostname!=host:
            raise SystemExit("OCI Object Storage redirected the PAR request to an unexpected host.")
        data=response.read(40*1024*1024+1)
except Exception as exc:
    raise SystemExit(f"Unable to download CrossShield sample data ({type(exc).__name__}); verify the PAR configuration and network access.")
if len(data)>40*1024*1024:
    raise SystemExit("CrossShield sample data exceeds the configured download limit.")
fd=os.open(sys.argv[1],os.O_WRONLY|os.O_TRUNC,0o600)
with os.fdopen(fd,"wb") as out: out.write(data)
print(f"[FSI] Downloaded {len(data)} bytes to {sys.argv[1]}")
PYTHON
echo "[FSI] Loading sample data from $data_file into $schema_name."
echo "[FSI] Running sequence synchronization from $sequence_sync_file."
sql -cloudconfig "$wallet_zip_path" "$schema_name/$FSI_DB_PASSWORD@$conn_db" @"$data_file"
sql -cloudconfig "$wallet_zip_path" "$schema_name/$FSI_DB_PASSWORD@$conn_db" @"$sequence_sync_file"
