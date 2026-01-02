#!/bin/bash
set -euo pipefail

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"
FIGURES_DIR="${BASE}/11_plots/figures"

echo "=========================================="
echo " Cleaning PLOTS & VISUALIZATION DIRECTORIES"
echo "=========================================="

if [ -d "$FIGURES_DIR" ]; then
    echo "Removing all files in ${FIGURES_DIR}..."
    rm -rf "${FIGURES_DIR:?}/"*
    echo "All plots removed successfully."
else
    echo "Figures directory does not exist. Creating it..."
    mkdir -p "$FIGURES_DIR"
    echo "Figures directory created."
fi
echo "✅ Cleanup completed."