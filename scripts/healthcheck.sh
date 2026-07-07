#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# healthcheck.sh
#
# Check whether llama-server is running and responding.
#
# Usage:
#
#   ./scripts/healthcheck.sh
#
# Optional environment variables:
#
#   HOST=localhost
#   PORT=8000
#
###############################################################################

HOST="${HOST:-localhost}"
PORT="${PORT:-8000}"

BASE_URL="http://${HOST}:${PORT}"

echo "============================================================"
echo "llama-server Health Check"
echo "============================================================"
echo "Endpoint : ${BASE_URL}"
echo

# ------------------------------------------------------------------------------
# Check server availability
# ------------------------------------------------------------------------------

if ! curl --silent --fail "${BASE_URL}/health" >/dev/null 2>&1; then
    echo "ERROR: Unable to reach llama-server."
    echo
    echo "Expected endpoint:"
    echo "  ${BASE_URL}/health"
    exit 1
fi

echo "✓ Server is reachable."

# ------------------------------------------------------------------------------
# Check models endpoint
# ------------------------------------------------------------------------------

echo
echo "Checking OpenAI-compatible API..."

MODEL_JSON=$(curl --silent --fail "${BASE_URL}/v1/models")

MODEL_ID=$(echo "${MODEL_JSON}" | python3 -c \
'import json,sys
try:
    data=json.load(sys.stdin)
    print(data["data"][0]["id"])
except Exception:
    sys.exit(1)')

echo "✓ OpenAI API is available."
echo "Loaded model: ${MODEL_ID}"

echo
echo "Health check completed successfully."