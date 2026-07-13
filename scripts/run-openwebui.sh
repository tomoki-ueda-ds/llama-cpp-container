#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="${HOME}/.config/llama-cpp-container"
CONFIG_FILE="${CONFIG_DIR}/model.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "ERROR: ${CONFIG_FILE} not found."
    exit 1
fi

source "${CONFIG_FILE}"

export DATA_DIR=/app/backend/data

exec /opt/open-webui/bin/open-webui serve \
    --host "${OPENWEBUI_HOST}" \
    --port "${OPENWEBUI_PORT}"