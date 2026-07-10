#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="${SCRIPT_DIR}/../config"

MODEL_CONF="${CONFIG_DIR}/model.conf"

if [[ ! -f "${MODEL_CONF}" ]]; then
    echo "ERROR: ${MODEL_CONF} not found."
    exit 1
fi

source "${MODEL_CONF}"

if [[ -z "${MODEL:-}" ]]; then
    echo "MODEL is not defined."
    exit 1
fi

exec "${SCRIPT_DIR}/start-server.sh" "${MODEL}"