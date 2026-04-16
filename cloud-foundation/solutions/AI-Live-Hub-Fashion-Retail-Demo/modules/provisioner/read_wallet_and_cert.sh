#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"

wallet_zip="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin)["wallet_zip"])')"
service_selector="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin)["service_selector"])')"

workdir="$(mktemp -d)"
cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT

if [[ ! -f "$wallet_zip" ]]; then
  python3 - <<PY
import json
print(json.dumps({"error": "Wallet zip not found: $wallet_zip"}))
PY
  exit 1
fi

unzip -oq "$wallet_zip" -d "$workdir"

tnsfile="$workdir/tnsnames.ora"

if [[ ! -f "$tnsfile" ]]; then
  python3 - <<PY
import json
print(json.dumps({"error": "tnsnames.ora not found in wallet zip: $wallet_zip"}))
PY
  exit 1
fi

python3 - "$tnsfile" "$service_selector" <<'PY'
import json
import re
import subprocess
import sys
from pathlib import Path

tns_path = Path(sys.argv[1])
selector = sys.argv[2].lower()

content = tns_path.read_text(encoding="utf-8", errors="ignore").replace("\r", "")

entries = {}
current_alias = None
buf = []

for line in content.splitlines():
    s = line.strip()
    if not s:
        continue
    m = re.match(r"^([A-Za-z0-9_.-]+)\s*=\s*(.*)$", s)
    if m:
        if current_alias:
            entries[current_alias] = " ".join(buf)
        current_alias = m.group(1)
        buf = [m.group(2)]
    elif current_alias:
        buf.append(s)

if current_alias:
    entries[current_alias] = " ".join(buf)

selected_alias = None
selected_value = None

for alias, value in entries.items():
    if alias.lower().endswith(selector) or alias.lower() == selector:
        selected_alias = alias
        selected_value = value
        break

if not selected_value:
    print(json.dumps({"error": f"No TNS entry found for selector: {selector}"}))
    sys.exit(1)

def extract(pattern, text):
    m = re.search(pattern, text, flags=re.IGNORECASE)
    return m.group(1).strip() if m else ""

host = extract(r"\(host\s*=\s*([^)]+)\)", selected_value)
port = extract(r"\(port\s*=\s*([^)]+)\)", selected_value)
service_name = extract(r"\(service_name\s*=\s*([^)]+)\)", selected_value)

if not host or not port or not service_name:
    print(json.dumps({"error": "Failed to parse HOST/PORT/SERVICE_NAME from tnsnames.ora"}))
    sys.exit(1)

cmd = f"openssl s_client -connect {host}:{port} -showcerts < /dev/null 2>/dev/null | openssl x509 -noout -subject -nameopt RFC2253 | sed 's/^subject=//'"
ssl_server_cert_dn = subprocess.check_output(cmd, shell=True, text=True).strip()

print(json.dumps({
    "tns_alias": selected_alias,
    "hostname": host,
    "port": port,
    "service_name": service_name,
    "ssl_server_cert_dn": ssl_server_cert_dn
}))
PY