#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    echo "  cp ${SCRIPT_DIR}/../config/model.conf.example \\"
    echo "     ~/.config/llama-cpp-container/model.conf"
    echo
    echo "Then edit the configuration file."
    echo
    exit 1
fi

# Load user configuration
# shellcheck disable=SC1090
source "${CONFIG_FILE}"

if [[ -z "${MODEL:-}" ]]; then
    echo
    echo "ERROR: MODEL is not defined in ${CONFIG_FILE}"
    exit 1
fi

if [[ ! -f "${MODEL}" ]]; then
    echo
    echo "ERROR: Model file not found:"
    echo "  ${MODEL}"
    exit 1
fi

echo "============================================================"
echo "Starting llama-server"
echo "============================================================"
echo "Model : ${MODEL}"
echo "Config: ${CONFIG_FILE}"
echo "============================================================"
echo

exec "${SCRIPT_DIR}/start-server.sh" "${MODEL}"