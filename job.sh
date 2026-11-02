#!/bin/bash
# ==============================================================================
# Unified Slurm / farm-run Job Script for Multimodal BIDS Session Analysis
# Compatible with:
#   - Homelab GPU Fleet: sbatch-local job.sh [--node victus|bci|localhost]
#   - FCUL LASIGE Farm:  sbatch-local job.sh --cluster lasige [--nodelist lotus]
#   - MACC Deucalion:    sbatch-local job.sh --cluster deucalion
# ==============================================================================
#SBATCH --job-name=bids_multimodal_analysis
#SBATCH --output=logs/%x_%A_%a.log
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --array=1-2%2

set -eo pipefail

# Ensure logs directory exists
mkdir -p logs

echo "===================================================================="
echo " Starting Multimodal BIDS Analysis Pipeline"
echo " Host:             $(hostname)"
echo " SLURM_JOB_ID:     ${SLURM_JOB_ID:-local}"
echo " SLURM_ARRAY_TASK: ${SLURM_ARRAY_TASK_ID:-all}"
echo " Start Time:       $(date)"
echo "===================================================================="

# Determine project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/nautilus_bci/scripts" ]; then
    WORKDIR="$SCRIPT_DIR/nautilus_bci/scripts"
elif [ -d "$SCRIPT_DIR/scripts" ]; then
    WORKDIR="$SCRIPT_DIR/scripts"
else
    WORKDIR="$SCRIPT_DIR"
fi

cd "$WORKDIR"
echo "[+] Working Directory: $(pwd)"

# Environment Detection (uv -> virtualenv -> conda -> system python)
if command -v uv &>/dev/null; then
    PY_CMD="uv run python"
elif [ -f "../.venv/bin/python" ]; then
    PY_CMD="../.venv/bin/python"
elif [ -f ".venv/bin/python" ]; then
    PY_CMD=".venv/bin/python"
elif [ -n "$CONDA_PREFIX" ]; then
    PY_CMD="python"
else
    PY_CMD="python3"
fi

echo "[+] Python Engine: $PY_CMD"

# Determine target session based on Slurm array task ID
TASK_ID="${SLURM_ARRAY_TASK_ID:-0}"

if [ "$TASK_ID" -eq 1 ]; then
    SESSIONS=("01")
elif [ "$TASK_ID" -eq 2 ]; then
    SESSIONS=("02")
else
    SESSIONS=("01" "02")
fi

# Run analysis for target session(s)
for SES in "${SESSIONS[@]}"; do
    echo ""
    echo "--------------------------------------------------------------------"
    echo " Processing: Subject 01 | Session $SES | Task leftright"
    echo "--------------------------------------------------------------------"

    # 1. Primary Comprehensive Multimodal Analysis
    $PY_CMD analysis/analyze_multimodal_bids_session.py \
        --bids-root bids_dataset_multimodal \
        --sub 01 \
        --ses "$SES" \
        --task leftright

    # 2. Neuroscience & Mind Map Activation Battery (GIF, MP4, Hotspots, Spectrograms, Roadmap)
    $PY_CMD analysis/generate_activation_mindmap_battery.py \
        --bids-root bids_dataset_multimodal \
        --sub 01 \
        --ses "$SES" \
        --task leftright

    echo "[✓] Finished Session $SES at $(date)"
done

echo ""
echo "===================================================================="
echo " All Multimodal BIDS Analyses Completed Successfully!"
echo " Results available in: results/multimodal_bids_analysis/"
echo " End Time: $(date)"
echo "===================================================================="
