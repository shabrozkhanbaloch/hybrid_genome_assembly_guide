#!/bin/bash
set -euo pipefail

# ===============================
# INPUT ARGUMENT
# ===============================
PROJECT_DIR=${1:-}

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: run_plots.sh <PROJECT_DIR>"
  exit 1
fi

PIPELINE_BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"
SCRIPT_DIR="$PIPELINE_BASE/11_plots/scripts"

RESULTS_DIR="$PROJECT_DIR/results"
FIGURES_DIR="$PROJECT_DIR/figures"

echo "=========================================="
echo " Generating ALL publication-ready plots"
echo " Project: $PROJECT_DIR"
echo "=========================================="

# -------------------------------
# Conda environment
# -------------------------------
eval "$(conda shell.bash hook)"
conda activate 09_plots

# ensure figures directory exists
mkdir -p "$FIGURES_DIR"

# -------------------------------
# Plot execution (CLI-safe)
# -------------------------------
echo "[1/8] CheckM2 assembly quality"
python "$SCRIPT_DIR/01_checkm2_assembly_quality.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "[2/8] BUSCO comparison"
python "$SCRIPT_DIR/02_busco_comparison.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "[3/8] QUAST N50 & contigs"
python "$SCRIPT_DIR/03_quast_n50_contigs.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "[4/8] GC content comparison"
python "$SCRIPT_DIR/04_gc_content_comparison.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "[5/8] Coverage depth comparison"
python "$SCRIPT_DIR/05_coverage_depth_comparison.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "[6/8] AMR gene comparison"
python "$SCRIPT_DIR/06_amr_gene_comparison.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "[7/8] geNomad classification summary"
python "$SCRIPT_DIR/07_genomad_summary.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "[8/8] Integrated overall assembly summary"
python "$SCRIPT_DIR/08_overall_assembly_summary.py" \
  --results "$RESULTS_DIR" \
  --figures "$FIGURES_DIR"

echo "=========================================="
echo " ALL PLOTS GENERATED SUCCESSFULLY"
echo " Output directory:"
echo "   $FIGURES_DIR"
echo "=========================================="
echo "✅ All plots completed."
