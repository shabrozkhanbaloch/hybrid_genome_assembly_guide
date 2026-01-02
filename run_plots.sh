#!/bin/bash
set -euo pipefail

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"
PLOT_DIR="$BASE/11_plots"
SCRIPT_DIR="$PLOT_DIR/scripts"
FIG_DIR="$PLOT_DIR/figures"

echo "=========================================="
echo " Generating ALL publication-ready plots"
echo "=========================================="

# activate plotting environment
eval "$(conda shell.bash hook)"
conda activate 09_plots

# ensure figures directory exists
mkdir -p "$FIG_DIR"

echo "[1/8] CheckM2 assembly quality"
python "$SCRIPT_DIR/01_checkm2_assembly_quality.py"

echo "[2/8] BUSCO comparison"
python "$SCRIPT_DIR/02_busco_comparison.py"

echo "[3/8] QUAST N50 & contigs"
python "$SCRIPT_DIR/03_quast_n50_contigs.py"

echo "[4/8] GC content comparison"
python "$SCRIPT_DIR/04_gc_content_comparison.py"

echo "[5/8] Coverage depth comparison"
python "$SCRIPT_DIR/05_coverage_depth_comparison.py"

echo "[6/8] AMR gene comparison"
python "$SCRIPT_DIR/06_amr_gene_comparison.py"

echo "[7/8] geNomad classification summary"
python "$SCRIPT_DIR/07_genomad_summary.py"

echo "[8/8] Integrated overall assembly summary"
python "$SCRIPT_DIR/08_overall_assembly_summary.py"

echo "=========================================="
echo " ALL PLOTS GENERATED SUCCESSFULLY"
echo " Output directory:"
echo "   $FIG_DIR"
echo "=========================================="
echo "✅ All plots completed."