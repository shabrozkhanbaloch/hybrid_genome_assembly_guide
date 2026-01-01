#!/bin/bash
set -euo pipefail

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"

echo "=========================================="
echo " Genome Quality Plotting Pipeline STARTED"
echo "=========================================="

########################################
# Environment check
########################################
echo "[INFO] Activating plotting environment..."
conda activate 05a_qc_plot

########################################
# 1. Genome quality comparison
########################################
echo "[1/6] Generating CheckM2 + BUSCO + QUAST comparison..."
python "$BASE/05a_compare_genome_quality.py"

########################################
# 2. Dotplots
########################################
echo "[2/6] Generating dotplots (genome & plasmids)..."
conda activate 05b_dotplot
python "$BASE/05b_generate_dotplots.py"

########################################
# 3. Coverage analysis (already mapped)
########################################
echo "[3/6] Plotting coverage profiles..."
conda activate 05a_qc_plot
python "$BASE/05c_plot_coverage.py"

########################################
# 4. GC bias analysis
########################################
echo "[4/6] Generating GC bias plots..."
python "$BASE/05c_gc_bias_analysis.py"

########################################
# 5. Coverage distribution dashboard
########################################
echo "[5/6] Generating coverage distribution dashboard..."
python "$BASE/05d_coverage_distribution_dashboard.py"

########################################
# 6. Plasmid copy number estimation
########################################
echo "[6/6] Estimating plasmid copy number..."
python "$BASE/05e_plasmid_copy_number.py"

########################################
# FINAL DASHBOARD
########################################
echo "[FINAL] Generating integrated genome quality dashboard..."
python "$BASE/05f_final_genome_quality_dashboard.py"

echo "=========================================="
echo " Plotting Pipeline COMPLETE"
echo "=========================================="

echo "Outputs saved in:"
echo "  06_genome_quality_assessment/"
echo "   ├── genome_quality_dashboard.html"
echo "   ├── coverage/"
echo "   ├── dotplots/"
echo "   ├── gc_bias/"
echo "   └── plasmid_copy_number/"
echo "=========================================="