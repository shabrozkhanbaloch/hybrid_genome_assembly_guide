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

DATA_DIR="$PROJECT_DIR/data"
RESULTS_DIR="$PROJECT_DIR/results"
FIGURES_DIR="$PROJECT_DIR/figures"
SCRIPTS_DIR="$(dirname "$0")"

mkdir -p "$RESULTS_DIR" "$FIGURES_DIR"

echo "=========================================="
echo " Hybrid Genome Assembly Pipeline STARTED"
echo " Project: $PROJECT_DIR"
echo "=========================================="

# =====================================================
# [1] Raw reads validation (READ-ONLY)
# =====================================================
echo "[1/10] Validating raw reads..."
bash "$SCRIPTS_DIR/01_setup_raw_reads.sh" "$DATA_DIR"

# =====================================================
# [2] QC before processing
# =====================================================
if compgen -G "$RESULTS_DIR/processed_reads/short_reads/*fastq.gz" > /dev/null; then
  echo "[2/10] QC before processing..."
  bash "$SCRIPTS_DIR/02_qc_reads_before_processing.sh" "$DATA_DIR" "$RESULTS_DIR"
else
  echo "[2/10] QC before processing already done — skipping"
fi

# =====================================================
# [3] Read processing
# =====================================================
if compgen -G "$RESULTS_DIR/processed_reads/short_reads/*_1.fastq.gz" > /dev/null; then
  echo "[3/10] Read processing already done — skipping"
else
  echo "[3/10] Processing reads..."
  bash "$SCRIPTS_DIR/03_process_reads.sh" "$DATA_DIR" "$RESULTS_DIR"
fi


# =====================================================
# [4] Genome assembly
# =====================================================
if \
  [[ -f "$RESULTS_DIR/assembly/01_short_only/assembly.fasta" ]] && \
  [[ -f "$RESULTS_DIR/assembly/02_long_only/assembly.fasta" ]] && \
  [[ -f "$RESULTS_DIR/assembly/03_hybrid/assembly.fasta" ]]; then

  echo "[4/10] Genome assembly already done — skipping"

else
  echo "[4/10] Genome assembly..."
  bash "$SCRIPTS_DIR/04_genome_assembly.sh" "$RESULTS_DIR"
fi

# =====================================================
# [5] Genome quality (CheckM2 + QUAST + BUSCO)
# =====================================================
if \
  [[ -f "$RESULTS_DIR/quality/checkm2/hybrid/quality_report.tsv" ]] && \
  [[ -f "$RESULTS_DIR/quality/quast/03_hybrid/transposed_report.tsv" ]] && \
  [[ -f "$RESULTS_DIR/quality/busco/hybrid/short_summary.txt" ]]; then

  echo "[5/10] Genome quality already done — skipping"

else
  echo "[5/10] Genome quality assessment..."
  bash "$SCRIPTS_DIR/05_genome_quality_assessment.sh" "$RESULTS_DIR"
fi


# =====================================================
# [5a] Coverage analysis
# =====================================================
if compgen -G "$RESULTS_DIR/quality/coverage/*/*depth*.txt" > /dev/null; then
  echo "[5a/10] Coverage already done — skipping"
else
  echo "[5a/10] Coverage analysis..."
  bash "$SCRIPTS_DIR/05a_coverage_analysis.sh" "$RESULTS_DIR"
fi


# =====================================================
# [6] Genome annotation
# =====================================================
if compgen -G "$RESULTS_DIR/annotation/prokka/03_hybrid/*.gff" > /dev/null; then
  echo "[6/10] Annotation already done — skipping"
else
  echo "[6/10] Genome annotation..."
  bash "$SCRIPTS_DIR/06_genome_annotation.sh" "$RESULTS_DIR"
fi

# =====================================================
# [7] Plasmid reconstruction (Plassembler)
# =====================================================
if [[ -f "$RESULTS_DIR/plasmids/plasmid_report.tsv" ]]; then
  echo "[7/10] Plasmids already reconstructed — skipping"
else
  echo "[7/10] Plasmid reconstruction..."
  bash "$SCRIPTS_DIR/07_plassembler.sh" "$RESULTS_DIR"
fi


# =====================================================
# [8] AMR detection (Abricate)
# =====================================================
if [[ -f "$RESULTS_DIR/amr/assembly_level/abricate_assembly_summary.tsv" ]] && \
   [[ -f "$RESULTS_DIR/amr/plasmid_level/abricate_plasmid_summary.tsv" ]]; then
  echo "[8/10] AMR analysis already done — skipping"
else
  echo "[8/10] AMR detection..."
  bash "$SCRIPTS_DIR/08_abricate.sh" "$RESULTS_DIR"
fi


# =====================================================
# [9] Prophage / virus detection (geNomad)
# =====================================================
if [[ -f "$RESULTS_DIR/prophage/assembly_level/assembly_summary/assembly_virus_summary.tsv" ]] && \
   compgen -G "$RESULTS_DIR/prophage/plasmid_level/*/plasmid_summary/*_virus_summary.tsv" > /dev/null; then
  echo "[9/10] geNomad already done — skipping"
else
  echo "[9/10] Prophage & virus detection..."
  bash "$SCRIPTS_DIR/09_genomad.sh" "$RESULTS_DIR"
fi


# =====================================================
# [10] Plots & summaries
# =====================================================
echo "[10/10] Generating plots & summaries..."
bash "$SCRIPTS_DIR/run_plots.sh" "$PROJECT_DIR"

echo "=========================================="
echo " Pipeline COMPLETED (RESUME-SAFE)"
echo " Results: $RESULTS_DIR"
echo " Figures: $FIGURES_DIR"
echo "=========================================="
