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

# shellcheck disable=SC1090
source "${CONFIG_FILE}"

if [[ -z "${AIDER_MODEL:-}" ]]; then
    echo
    echo "ERROR: AIDER_MODEL is not defined in ${CONFIG_FILE}"
    exit 1
fi

export OPENAI_API_BASE
export OPENAI_API_KEY

echo "=============================================="
echo "Starting aider"
echo "=============================================="
echo "API Base : ${OPENAI_API_BASE}"
echo "Model    : ${AIDER_MODEL}"
echo

exec aider \
    --model "${AIDER_MODEL}" \
    "$@"