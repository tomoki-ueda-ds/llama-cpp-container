#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# run-chat.sh
#
# Interactive terminal chat client for llama-server.
#
# Usage:
#
#   bash run-chat.sh
#
# Configuration:
#
#   ~/.config/llama-cpp-container/model.conf
#
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FILE="${HOME}/.config/llama-cpp-container/model.conf"

###############################################################################
# Configuration check
###############################################################################

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

###############################################################################
# Load configuration
###############################################################################

# shellcheck disable=SC1090
source "${CONFIG_FILE}"

###############################################################################
# Required variables
###############################################################################

required_vars=(
    MODEL
    MODEL_ALIAS
    OPENAI_API_BASE
    OPENAI_API_KEY
)

for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo
        echo "ERROR: ${var} is not defined in ${CONFIG_FILE}"
        exit 1
    fi
done

###############################################################################
# Export OpenAI-compatible environment variables
###############################################################################

export OPENAI_API_BASE
export OPENAI_API_KEY

###############################################################################
# Display configuration
###############################################################################

echo "============================================================"
echo "Interactive Chat"
echo "============================================================"
echo "Model     : ${MODEL_ALIAS}"
echo "API Base  : ${OPENAI_API_BASE}"
echo "Config    : ${CONFIG_FILE}"
echo "============================================================"
echo

###############################################################################
# Launch chat client
###############################################################################

exec python3 "${SCRIPT_DIR}/chat.py" "$@"