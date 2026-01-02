#!/bin/bash
set -euo pipefail

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment"

echo "=========================================="
echo " Cleaning PLOTS & VISUALIZATION DIRECTORIES"
echo "=========================================="

########################################
# 1. Remove all files in figures directory
########################################
FIGURES_DIR="${BASE}/11_plots/figures"
if [ -d "$FIGURES_DIR" ]; then
    echo "Removing all files in ${FIGURES_DIR}..."
    rm -rf "${FIGURES_DIR:?}/"*
    echo "All files removed from ${FIGURES_DIR}."
else
    echo "Directory ${FIGURES_DIR} does not exist. Creating it now..."
    mkdir -p "$FIGURES_DIR"
    echo "Directory ${FIGURES_DIR} created."
fi  
########################################
