#!/usr/bin/env bash
set -euo pipefail

VARIABLES_FILE="${VARIABLES_FILE:-variables.tf}"

get_tf_default() {
  local var_name="$1"
  local file="$2"

  python3 - "$var_name" "$file" <<'PY'
import re
import sys

var_name = sys.argv[1]
file_path = sys.argv[2]

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
except FileNotFoundError:
    print("")
    sys.exit(0)

pattern = re.compile(
    r'variable\s+"{}"\s*\{{.*?default\s*=\s*"([^"]+)".*?\}}'.format(re.escape(var_name)),
    re.DOTALL
)

match = pattern.search(content)
print(match.group(1) if match else "")
PY
}

BUCKET_1="${1:-$(get_tf_default files_bucket_name "$VARIABLES_FILE")}"
BUCKET_2="${2:-$(get_tf_default atp_creds_bucket_name "$VARIABLES_FILE")}"

if [ -z "${BUCKET_1:-}" ]; then
  BUCKET_1="AgenticAiFiles"
fi

if [ -z "${BUCKET_2:-}" ]; then
  BUCKET_2="AgenticATPCreds"
fi

NAMESPACE="$(oci os ns get --query 'data' --raw-output)"
BUCKETS=("${BUCKET_1}" "${BUCKET_2}")

echo "Using buckets:"
echo "  files bucket      = ${BUCKET_1}"
echo "  atp creds bucket  = ${BUCKET_2}"
echo "  namespace         = ${NAMESPACE}"

for BUCKET in "${BUCKETS[@]}"; do
  echo "=================================================="
  echo "Cleaning bucket: ${BUCKET}"
  echo "Namespace: ${NAMESPACE}"
  echo "=================================================="

  while true; do
    TMP_JSON="$(mktemp)"
    oci os object list-object-versions \
      --namespace-name "${NAMESPACE}" \
      --bucket-name "${BUCKET}" \
      --all \
      --output json > "${TMP_JSON}" 2>/dev/null || true

    COUNT="$(python3 - "${TMP_JSON}" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f).get("data", [])
    print(len(data))
except Exception:
    print(0)
PY
)"
    if [ "${COUNT}" = "0" ]; then
      rm -f "${TMP_JSON}"
      break
    fi

    python3 - "${TMP_JSON}" "${NAMESPACE}" "${BUCKET}" <<'PY'
import json
import subprocess
import sys

path = sys.argv[1]
namespace = sys.argv[2]
bucket = sys.argv[3]

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f).get("data", [])

for item in data:
    name = item.get("name")
    version_id = item.get("version-id")
    if name and version_id:
        subprocess.run([
            "oci", "os", "object", "delete",
            "--namespace-name", namespace,
            "--bucket-name", bucket,
            "--name", name,
            "--version-id", version_id,
            "--force"
        ], check=False)
PY

    rm -f "${TMP_JSON}"
    sleep 2
  done

  while true; do
    TMP_JSON="$(mktemp)"
    oci os object list \
      --namespace-name "${NAMESPACE}" \
      --bucket-name "${BUCKET}" \
      --all \
      --output json > "${TMP_JSON}" 2>/dev/null || true

    COUNT="$(python3 - "${TMP_JSON}" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f).get("data", [])
    print(len(data))
except Exception:
    print(0)
PY
)"
    if [ "${COUNT}" = "0" ]; then
      rm -f "${TMP_JSON}"
      break
    fi

    python3 - "${TMP_JSON}" "${NAMESPACE}" "${BUCKET}" <<'PY'
import json
import subprocess
import sys

path = sys.argv[1]
namespace = sys.argv[2]
bucket = sys.argv[3]

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f).get("data", [])

for item in data:
    name = item.get("name")
    if name:
        subprocess.run([
            "oci", "os", "object", "delete",
            "--namespace-name", namespace,
            "--bucket-name", bucket,
            "--name", name,
            "--force"
        ], check=False)
PY

    rm -f "${TMP_JSON}"
    sleep 2
  done

  echo "Bucket cleaned: ${BUCKET}"
done

echo "All requested buckets were cleaned."