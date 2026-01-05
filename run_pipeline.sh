#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# Hybrid Genome Assembly Pipeline (RESUME-SAFE)
# Author: shabroz
# ==================================================

# -----------------------------
# INPUTS
# -----------------------------
PROJECT_DIR=${1:-}
START_STEP=${2:-1}   # default: start from step 1

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: run_pipeline.sh <PROJECT_DIR> [START_STEP]"
  echo "Example:"
  echo "  run_pipeline.sh paper_03"
  echo "  run_pipeline.sh paper_03 5"
  exit 1
fi

# -----------------------------
# PATHS
# -----------------------------
PIPELINE_BASE="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$PROJECT_DIR/data"
RESULTS_DIR="$PROJECT_DIR/results"
FIGURES_DIR="$PROJECT_DIR/figures"
SCRIPTS="$PIPELINE_BASE"

mkdir -p "$RESULTS_DIR" "$FIGURES_DIR"

echo "=========================================="
echo " Hybrid Genome Assembly Pipeline"
echo " Project: $PROJECT_DIR"
echo " Start step: $START_STEP"
echo "=========================================="

# ==================================================
# Helper: run step only if output missing
# ==================================================
run_step () {
  local STEP_NUM=$1
  local STEP_NAME=$2
  local CHECK_FILE=$3
  shift 3
  local CMD="$@"

  if (( STEP_NUM < START_STEP )); then
    echo "[$STEP_NUM] $STEP_NAME — skipped (before start step)"
    return
  fi

  if [[ -f "$CHECK_FILE" ]]; then
    echo "[$STEP_NUM] $STEP_NAME — already done, skipping"
  else
    echo "[$STEP_NUM] $STEP_NAME — running"
    eval "$CMD"
  fi
}

# ==================================================
# STEP 1 — Validate raw reads (READ-ONLY)
# ==================================================
run_step 1 "Raw read validation" \
  "$DATA_DIR/short_reads" \
  "bash $SCRIPTS/01_setup_raw_reads.sh $DATA_DIR"

# ==================================================
# STEP 2 — QC before processing
# ==================================================
run_step 2 "QC before processing" \
  "$RESULTS_DIR/qc_before/short_reads/multiqc/multiqc_report.html" \
  "bash $SCRIPTS/02_qc_reads_before_processing.sh $DATA_DIR $RESULTS_DIR"

# ==================================================
# STEP 3 — Read processing
# ==================================================
run_step 3 "Read processing" \
  "$RESULTS_DIR/processed_reads/short_reads/processed_1.fastq.gz" \
  "bash $SCRIPTS/03_process_reads.sh $DATA_DIR $RESULTS_DIR"

# ==================================================
# STEP 4 — Genome assembly
# ==================================================
run_step 4 "Genome assembly" \
  "$RESULTS_DIR/assembly/03_hybrid/assembly.fasta" \
  "bash $SCRIPTS/04_genome_assembly.sh $RESULTS_DIR"

# ==================================================
# STEP 5 — Genome quality (CheckM2 + QUAST + BUSCO)
# ==================================================
run_step 5 "Genome quality assessment" \
  "$RESULTS_DIR/quality/checkm2/hybrid/quality_report.tsv" \
  "bash $SCRIPTS/05_genome_quality_assessment.sh $RESULTS_DIR"

# ==================================================
# STEP 5a — Coverage analysis
# ==================================================
run_step 6 "Coverage analysis" \
  "$RESULTS_DIR/quality/coverage/short_reads/short_vs_hybrid/depth.txt" \
  "bash $SCRIPTS/05a_coverage_analysis.sh $RESULTS_DIR"

# ==================================================
# STEP 6 — Genome annotation
# ==================================================
run_step 7 "Genome annotation" \
  "$RESULTS_DIR/annotation/bakta/03_hybrid/*.gff" \
  "bash $SCRIPTS/06_genome_annotation.sh $RESULTS_DIR"

# ==================================================
# STEP 7 — Plasmid reconstruction
# ==================================================
run_step 8 "Plasmid reconstruction (Plassembler)" \
  "$RESULTS_DIR/plasmids/plassembler_plasmids.fasta" \
  "bash $SCRIPTS/07_plassembler.sh $RESULTS_DIR"

# ==================================================
# STEP 8 — AMR detection
# ==================================================
run_step 9 "AMR detection (Abricate)" \
  "$RESULTS_DIR/amr/assembly_level/abricate_assembly_summary.tsv" \
  "bash $SCRIPTS/08_abricate.sh $PROJECT_DIR"

# ==================================================
# STEP 9 — Prophage / virus detection
# ==================================================
run_step 10 "Prophage detection (geNomad)" \
  "$RESULTS_DIR/prophage/assembly_level/*summary*.tsv" \
  "bash $SCRIPTS/09_genomad.sh $RESULTS_DIR"

# ==================================================
# STEP 10 — Plots
# ==================================================
echo "[11] Generating plots"
bash "$SCRIPTS/run_plots.sh" "$PROJECT_DIR"

echo "=========================================="
echo " PIPELINE COMPLETED (RESUME-SAFE)"
echo " Project: $PROJECT_DIR"
echo " Results: $RESULTS_DIR"
echo " Figures: $FIGURES_DIR"
echo "=========================================="


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
if [[ -f "$RESULTS_DIR/quality/checkm2/hybrid/quality_report.tsv" ]]; then
  echo "[5/8] Genome quality assessment already done — skipping"
else
  echo "[5/8] Genome quality assessment..."
  bash "$SCRIPTS_DIR/05_genome_quality_assessment.sh" "$RESULTS_DIR"
fi

# -------------------------------------------------
# Step 5a – Coverage
# -------------------------------------------------
if compgen -G "$RESULTS_DIR/quality/coverage/**/depth*.txt" > /dev/null; then
  echo "[5a] Coverage already done — skipping"
else
  echo "[5a] Coverage analysis..."
  bash "$SCRIPTS_DIR/05a_coverage_analysis.sh" "$RESULTS_DIR"
fi

# -------------------------------------------------
# Step 6 – Annotation
# -------------------------------------------------
if [[ -f "$RESULTS_DIR/annotation/prokka/03_hybrid/*.gff" ]]; then
  echo "[6/8] Annotation already exists — skipping"
else
  echo "[6/8] Genome annotation..."
  bash "$SCRIPTS_DIR/06_genome_annotation.sh" "$RESULTS_DIR"
fi


# -------------------------------------------------
# [7] Plasmid reconstruction (Plassembler)
# -------------------------------------------------
if [[ -f "$RESULTS_DIR/plasmids/plassembler_plasmids.fasta" ]]; then
  echo "[7/9] Plasmids already reconstructed — skipping"
else
  echo "[7/9] Plasmid reconstruction (Plassembler)..."
  bash "$SCRIPTS_DIR/07_plassembler.sh" "$RESULTS_DIR"
fi


# -------------------------------------------------
# [8] AMR detection (Abricate)
# -------------------------------------------------
if compgen -G "$RESULTS_DIR/amr/*/*summary*.tsv" > /dev/null; then
  echo "[8/9] AMR analysis already done — skipping"
else
  echo "[8/9] AMR detection (Abricate)..."
  bash "$SCRIPTS_DIR/08_abricate.sh" "$PROJECT_DIR"
fi


# -------------------------------------------------
# [9] Prophage / virus detection (geNomad)
# -------------------------------------------------
if compgen -G "$RESULTS_DIR/prophage/*/*summary*.tsv" > /dev/null; then
  echo "[9/9] geNomad already done — skipping"
else
  echo "[9/9] Prophage & virus detection (geNomad)..."
  bash "$SCRIPTS_DIR/09_genomad.sh" "$RESULTS_DIR"
fi


# -------------------------------------------------
# [10] Plots & summaries
# -------------------------------------------------
echo "[10] Generating plots & summaries..."
bash "$SCRIPTS_DIR/run_plots.sh" "$PROJECT_DIR"


echo "=========================================="
echo " Pipeline COMPLETED (FULL & RESUME-SAFE)"
echo " Results: $RESULTS_DIR"
echo "=========================================="