#!/bin/bash
set -euo pipefail

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment"

echo "=========================================="
echo " Cleaning PLOTS & VISUALIZATION DIRECTORIES"
echo "=========================================="

########################################
# 1. Remove coverage plots & data
########################################
echo "[1/5] Removing coverage directory..."
rm -rf "$BASE/coverage" || true

########################################
# 2. Remove dotplots
########################################
echo "[2/5] Removing dotplots directory..."
rm -rf "$BASE/dotplots" || true

########################################
# 3. Remove GC bias plots
########################################
echo "[3/5] Removing GC bias directory..."
rm -rf "$BASE/gc_bias" || true

########################################
# 4. Remove plasmid copy number plots
########################################
echo "[4/5] Removing plasmid copy number directory..."
rm -rf "$BASE/plasmid_copy_number" || true

########################################
# 5. Remove leftover HTML files (safety)
########################################
echo "[5/5] Removing stray HTML files..."
find "$BASE" -type f -name "*.html" -delete || true

echo "=========================================="
echo " Plot directories cleanup COMPLETE"
echo "=========================================="

echo "Retained (SAFE):"
echo " - checkm2/"
echo " - busco/"
echo " - quast/"
