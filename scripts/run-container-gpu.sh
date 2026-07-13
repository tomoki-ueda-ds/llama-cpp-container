#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:-llama-cpp-container_latest.sif}"

apptainer shell \
    --nv \
    --bind "${HOME}/models:/models" \
    --bind "${HOME}/.config:/home/${USER}/.config" \
    "${IMAGE}"