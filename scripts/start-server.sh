#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# start-server.sh
#
# Launch llama-server using the shared configuration file.
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/llama-server.conf"

if [[ $# -ne 1 ]]; then
    echo "Usage:"
    echo "  $0 <model.gguf>"
    exit 1
fi

MODEL_PATH="$1"

if [[ ! -f "${MODEL_PATH}" ]]; then
    echo "ERROR: Model not found:"
    echo "  ${MODEL_PATH}"
    exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "ERROR: Configuration file not found:"
    echo "  ${CONFIG_FILE}"
    exit 1
fi

echo "============================================================"
echo "Starting llama-server"
echo "============================================================"
echo "Model : ${MODEL_PATH}"
echo "Config: ${CONFIG_FILE}"
echo "Host  : 0.0.0.0"
echo "Port  : 18000"
echo "============================================================"

ARGS=()

while IFS= read -r line; do
    # Skip comments and blank lines
    [[ -z "${line}" ]] && continue
    [[ "${line}" =~ ^[[:space:]]*# ]] && continue

    read -ra words <<< "${line}"
    ARGS+=("${words[@]}")
done < "${CONFIG_FILE}"

exec llama-server \
    -m "${MODEL_PATH}" \
    "${ARGS[@]}"