#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
PROJECT_DIR=${1:-}

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: run_pipeline.sh <PROJECT_DIR>"
  exit 1
fi

# ===============================
# DIRECTORY STRUCTURE
# ===============================
DATA_DIR="$PROJECT_DIR/data"
RESULTS_DIR="$PROJECT_DIR/results"
SCRIPTS_DIR="$(dirname "$0")"

mkdir -p "$RESULTS_DIR"

echo "=========================================="
echo " Hybrid Genome Assembly Pipeline STARTED"
echo " Project: $PROJECT_DIR"
echo "=========================================="

# ===============================
# [1/8] Validate raw reads (READ-ONLY)
# ===============================
echo "[1/8] Setting up raw reads..."
bash "$SCRIPTS_DIR/01_setup_raw_reads.sh" "$DATA_DIR"

# ===============================
# [2/8] QC before processing
# ===============================
echo "[2/8] QC before processing..."
bash "$SCRIPTS_DIR/02_qc_reads_before_processing.sh" \
  "$DATA_DIR" \
  "$RESULTS_DIR"

# ===============================
# [3/8] Read processing
# ===============================
echo "[3/8] Processing reads..."
bash "$SCRIPTS_DIR/03_process_reads.sh" \
  "$DATA_DIR" \
  "$RESULTS_DIR"

# ===============================
# [4/8] Genome assembly
# ===============================
echo "[4/8] Genome assembly..."
bash "$SCRIPTS_DIR/04_genome_assembly.sh" \
  "$RESULTS_DIR"

# ===============================
# [5/8] QC after assembly
# ===============================
echo "[5/8] QC after assembly..."
bash "$SCRIPTS_DIR/05_qc_after_assembly.sh" \
  "$RESULTS_DIR"

# ===============================
# [6/8] Genome annotation
# ===============================
echo "[6/8] Genome annotation..."
bash "$SCRIPTS_DIR/06_genome_annotation.sh" \
  "$RESULTS_DIR"

# ===============================
# [7/8] AMR / mobile elements
# ===============================
echo "[7/8] AMR & mobile element analysis..."
bash "$SCRIPTS_DIR/07_amr_mobile_elements.sh" \
  "$RESULTS_DIR"

# ===============================
# [8/8] Plots & summary
# ===============================
echo "[8/8] Generating plots & summaries..."
bash "$SCRIPTS_DIR/08_plots_and_summary.sh" \
  "$RESULTS_DIR"

echo "=========================================="
echo " Pipeline COMPLETED successfully"
echo " Results: $RESULTS_DIR"
echo "=========================================="
