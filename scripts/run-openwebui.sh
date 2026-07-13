#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="${HOME}/.config/llama-cpp-container/model.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo
    echo "ERROR: Configuration file not found."
    echo
    echo "Expected:"
    echo "  ${CONFIG_FILE}"
    echo
    echo "Create it with:"
    echo
    echo "  mkdir -p ~/.config/llama-cpp-container"
    echo "  cp /workspace/config/model.conf.example \\"
    echo "     ~/.config/llama-cpp-container/model.conf"
    echo
    exit 1
fi

# shellcheck disable=SC1090
source "${CONFIG_FILE}"

export OPENAI_API_BASE
export OPENAI_API_KEY

mkdir -p "${HOME}/.local/share/open-webui"

echo "=============================================="
echo "Starting Open WebUI"
echo "=============================================="
echo "WebUI : http://${OPENWEBUI_HOST}:${OPENWEBUI_PORT}"
echo "LLM   : ${OPENAI_API_BASE}"
echo

exec open-webui serve \
    --host "${OPENWEBUI_HOST}" \
    --port "${OPENWEBUI_PORT}"