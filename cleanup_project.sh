#!/usr/bin/env bash
set -euo pipefail

# ===============================
# INPUT ARGUMENT
# ===============================
PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
  echo "Usage: cleanup_project.sh <PROJECT_DIR>"
  exit 1
fi

RESULTS="$PROJECT_DIR/results"
FIGURES="$PROJECT_DIR/figures"

echo "=============================================="
echo " Project cleanup (SAFE MODE)"
echo " Target: $PROJECT_DIR"
echo "=============================================="

# -------------------------------------------------
# QC outputs (raw reports only)
# -------------------------------------------------
rm -rf "$RESULTS/qc_before"/*
rm -rf "$RESULTS/qc_after"/*

# -------------------------------------------------
# Genome assembly
# KEEP: assembly.fasta
# -------------------------------------------------
find "$RESULTS/assembly" -type f ! -name "assembly.fasta" -delete

# -------------------------------------------------
# Genome quality assessment
# KEEP: summary TSVs if any
# -------------------------------------------------
rm -rf "$RESULTS/quality/checkm2"
rm -rf "$RESULTS/quality/quast"
rm -rf "$RESULTS/quality/busco"
rm -rf "$RESULTS/quality/coverage"

# -------------------------------------------------
# Genome annotation
# KEEP: GFF + summary TSVs
# -------------------------------------------------
find "$RESULTS/annotation/prokka" -type f \
  ! -name "*.gff" \
  ! -name "*.tsv" \
  -delete

find "$RESULTS/annotation/bakta" -type f \
  ! -name "*.gff" \
  ! -name "*.tsv" \
  -delete

# -------------------------------------------------
# Plassembler
# KEEP: summaries + logs
# -------------------------------------------------
find "$RESULTS/plasmids" -type f \
  ! -name "*summary*.tsv" \
  ! -name "*.log" \
  -delete

# -------------------------------------------------
# Abricate
# KEEP: summary TSVs
# -------------------------------------------------
find "$RESULTS/amr" -type f \
  ! -name "*summary*.tsv" \
  -delete

# -------------------------------------------------
# geNomad
# KEEP: summary folders only
# -------------------------------------------------
find "$RESULTS/prophage" -type f \
  ! -name "*summary*" \
  -delete

# -------------------------------------------------
# Generic heavy junk
# -------------------------------------------------
find "$RESULTS" -type f \( \
  -name "*.bam" -o \
  -name "*.bai" -o \
  -name "*.depth*" -o \
  -name "*.paf" -o \
  -name "*.html" -o \
  -name "*.json" \
\) -delete

echo "----------------------------------------------"
echo " Cleanup complete (SAFE)"
echo " Results kept:"
echo "  - assembly.fasta"
echo "  - summary TSVs"
echo "  - figures/"
echo "----------------------------------------------"
