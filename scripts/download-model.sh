#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# download-model.sh
#
# Download a GGUF model from Hugging Face Hub.
#
# Usage:
#
#   ./scripts/download-model.sh <repo_id> <filename> [destination]
#
# Example:
#
#   ./scripts/download-model.sh \
#       bartowski/Qwen2.5-Coder-32B-Instruct-GGUF \
#       Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf
#
###############################################################################

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Usage:"
    echo "  $0 <repo_id> <filename> [destination]"
    echo
    echo "Example:"
    echo "  $0 bartowski/Qwen2.5-Coder-32B-Instruct-GGUF \\"
    echo "     Qwen2.5-Coder-32B-Instruct-Q5_K_M.gguf"
    exit 1
fi

REPO_ID="$1"
FILENAME="$2"
DESTINATION="${3:-${HOME}/models}"

mkdir -p "${DESTINATION}"

echo "============================================================"
echo "Downloading GGUF model"
echo "============================================================"
echo "Repository : ${REPO_ID}"
echo "File       : ${FILENAME}"
echo "Destination: ${DESTINATION}"
echo "============================================================"

python3 -m huggingface_hub download \
    "${REPO_ID}" \
    "${FILENAME}" \
    --local-dir "${DESTINATION}"

echo
echo "Download completed."

echo
echo "Installed model:"
ls -lh "${DESTINATION}/${FILENAME}"