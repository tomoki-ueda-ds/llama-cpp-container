#!/usr/bin/env bash

set -euo pipefail

export OPENAI_API_BASE="${OPENAI_API_BASE:-http://localhost:18000/v1}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-dummy}"

echo "=============================================="
echo "Starting aider"
echo "=============================================="
echo "API Base : ${OPENAI_API_BASE}"
echo

exec aider "$@"