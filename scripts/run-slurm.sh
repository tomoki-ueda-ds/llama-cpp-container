#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# run-slurm.sh
#
# Start llama-server inside a Slurm batch job.
#
# Usage:
#
#   ./scripts/run-slurm.sh /models/<model>.gguf
#
# Example (inside sbatch script):
#
#   apptainer exec \
#       --nv \
#       --bind $HOME/models:/models \
#       llama-cpp-container.sif \
#       ./scripts/run-slurm.sh \
#       /models/qwen2.5-coder-32b-instruct-q5_k_m.gguf
#
###############################################################################

if [[ $# -ne 1 ]]; then
    echo "Usage:"
    echo "  $0 <model.gguf>"
    exit 1
fi

MODEL_PATH="$1"

echo "============================================================"
echo "Slurm Job Information"
echo "============================================================"

echo "Job ID      : ${SLURM_JOB_ID:-N/A}"
echo "Job Name    : ${SLURM_JOB_NAME:-N/A}"
echo "Node        : $(hostname)"
echo "User        : ${USER}"
echo "Working Dir : $(pwd)"
echo "Model       : ${MODEL_PATH}"

echo "============================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "${SCRIPT_DIR}/start-server.sh" "${MODEL_PATH}"