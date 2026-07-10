#!/usr/bin/env bash

set -euo pipefail

echo "=============================================="
echo "llama-cpp-container"
echo "=============================================="

echo
python3 --version

echo
llama-server --version || true

echo
aider --version || true

echo
echo "Available models"

if [[ -d /models ]]; then
    find /models -type f -name "*.gguf"
else
    echo "/models is not mounted."
fi

echo
echo "Commands"

echo
echo "  ./scripts/run-server.sh"

echo
echo "  ./scripts/run-aider.sh"

echo

exec /bin/bash