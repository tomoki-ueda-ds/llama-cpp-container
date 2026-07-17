#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="${HOME}/.config/llama-cpp-container/model.conf"
source "${CONFIG_FILE}"

export DATA_DIR="${HOME}/.local/share/open-webui"

# llama.cpp(OpenAI互換API)
export OPENAI_API_BASE
export OPENAI_API_KEY

echo "=============================================="
echo "Starting Open WebUI"
echo "=============================================="
echo "Host : ${OPENWEBUI_HOST}"
echo "Port : ${OPENWEBUI_PORT}"
echo "Data : ${DATA_DIR}"
echo "API  : ${OPENAI_API_BASE}"
echo

exec /opt/open-webui/bin/open-webui serve \
    --host "${OPENWEBUI_HOST}" \
    --port "${OPENWEBUI_PORT}"