#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# start-server.sh
#
# Launch llama-server using the shared configuration file.
#
# Example:
#
#   ./scripts/start-server.sh \
#       /models/qwen2.5-coder-32b-instruct-q5_k_m.gguf
#
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
echo "Port  : 8000"
echo "============================================================"

exec llama-server \
    -m "${MODEL_PATH}" \
    $(grep -v '^[[:space:]]*#' "${CONFIG_FILE}" | grep -v '^[[:space:]]*$')