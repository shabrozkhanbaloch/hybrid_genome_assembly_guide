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

# -------------------------------------------------
# Step 5 – Genome quality
# -------------------------------------------------
if [[ ! -d "$RESULTS_DIR/quality/checkm2" ]]; then
  echo "[5/8] Genome quality assessment..."
  bash "$SCRIPTS_DIR/05_genome_quality_assessment.sh" "$RESULTS_DIR"
else
  echo "[5/8] Quality assessment already done — skipping"
fi

# -------------------------------------------------
# Step 5a – Coverage
# -------------------------------------------------
if [[ ! -d "$RESULTS_DIR/quality/coverage" ]]; then
  echo "[5a] Coverage analysis..."
  bash "$SCRIPTS_DIR/05a_coverage_analysis.sh" "$RESULTS_DIR"
else
  echo "[5a] Coverage already done — skipping"
fi

# -------------------------------------------------
# Step 6 – Annotation
# -------------------------------------------------
if [[ ! -d "$RESULTS_DIR/annotation" ]]; then
  echo "[6/8] Genome annotation..."
  bash "$SCRIPTS_DIR/06_genome_annotation.sh" "$RESULTS_DIR"
else
  echo "[6/8] Annotation already exists — skipping"
fi

# -------------------------------------------------
# [7] Plasmid reconstruction (Plassembler)
# -------------------------------------------------
if [[ ! -d "$RESULTS_DIR/plasmids" ]]; then
  echo "[7/9] Plasmid reconstruction (Plassembler)..."
  bash "$SCRIPTS_DIR/07_plassembler.sh" "$RESULTS_DIR"
else
  echo "[7/9] Plasmids already reconstructed — skipping"
fi

# -------------------------------------------------
# [8] AMR detection (Abricate)
# -------------------------------------------------
if [[ ! -d "$RESULTS_DIR/amr" ]]; then
  echo "[8/9] AMR detection (Abricate)..."
  bash "$SCRIPTS_DIR/08_abricate.sh" "$PROJECT_DIR"
else
  echo "[8/9] AMR analysis already done — skipping"
fi

# -------------------------------------------------
# [9] Prophage / virus detection (geNomad)
# -------------------------------------------------
if [[ ! -d "$RESULTS_DIR/prophage" ]]; then
  echo "[9/9] Prophage & virus detection (geNomad)..."
  bash "$SCRIPTS_DIR/09_genomad.sh" "$RESULTS_DIR"
else
  echo "[9/9] geNomad already done — skipping"
fi

# -------------------------------------------------
# [10] Plots & summaries
# -------------------------------------------------
echo "[10] Generating plots & summaries..."
bash "$SCRIPTS_DIR/run_plots.sh" "$RESULTS_DIR"

echo "=========================================="
echo " Pipeline COMPLETED (FULL & RESUME-SAFE)"
echo " Results: $RESULTS_DIR"
echo "=========================================="