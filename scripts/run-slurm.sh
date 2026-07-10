#!/usr/bin/env bash

set -euo pipefail

echo "=============================================="
echo "Slurm Job"
echo "=============================================="

echo "Job ID : ${SLURM_JOB_ID:-N/A}"
echo "Node   : $(hostname)"
echo "User   : ${USER}"

echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "${SCRIPT_DIR}/run-server.sh"