#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:-llama-cpp-container_latest.sif}"

apptainer shell \
    --bind "${HOME}/.config:/home/${USER}/.config" \
    --bind "${HOME}/.local/share/open-webui:/app/backend/data" \
    "${IMAGE}"