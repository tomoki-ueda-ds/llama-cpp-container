#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="${HOME}/.config/llama-cpp-container"
CONFIG_FILE="${CONFIG_DIR}/model.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "ERROR: ${CONFIG_FILE} not found."
    exit 1
fi

# shellcheck disable=SC1090
source "${CONFIG_FILE}"

export DATA_DIR="${HOME}/.local/share/open-webui"

export OPENAI_API_BASE
export OPENAI_API_KEY

mkdir -p "${DATA_DIR}"

echo "=============================================="
echo "Starting Open WebUI"
echo "=============================================="
echo "Host : ${OPENWEBUI_HOST}"
echo "Port : ${OPENWEBUI_PORT}"
echo "Data : ${DATA_DIR}"
echo

exec open-webui serve \
    --host "${OPENWEBUI_HOST}" \
    --port "${OPENWEBUI_PORT}"