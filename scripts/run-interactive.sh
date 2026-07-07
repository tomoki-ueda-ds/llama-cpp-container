#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# run-interactive.sh
#
# Interactive development environment for llama.cpp container.
#
# Usage:
#
#   ./scripts/run-interactive.sh
#
###############################################################################

echo "============================================================"
echo "llama-cpp-container"
echo "Interactive Development Environment"
echo "============================================================"

echo
echo "Python:"
python3 --version

echo
echo "llama-server:"
llama-server --version || true

echo
echo "aider:"
aider --version || true

echo
echo "Working directory:"
pwd

echo
echo "Available models:"
if [ -d "/models" ]; then
    find /models -maxdepth 1 -name "*.gguf" -printf "  %f\n"
else
    echo "  /models is not mounted."
fi

echo
echo "Useful commands:"
echo
echo "  Start llama-server"
echo "    ./scripts/start-server.sh /models/<model>.gguf"
echo
echo "  Start aider"
echo "    export OPENAI_API_BASE=http://localhost:8000/v1"
echo "    export OPENAI_API_KEY=dummy"
echo "    aider"
echo
echo "============================================================"
echo

exec /bin/bash