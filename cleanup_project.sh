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

echo "=============================================="
echo " Project cleanup (QC → Genomad)"
echo " Target: $PROJECT_DIR"
echo "=============================================="

# -------------------------------------------------
# QC outputs
# -------------------------------------------------
rm -rf "$RESULTS/qc_before"/*
rm -rf "$RESULTS/qc_after"/*

# -------------------------------------------------
# Genome assembly (KEEP FASTA ONLY)
# -------------------------------------------------
find "$RESULTS/assembly" -type f ! -name "assembly.fasta" -delete

# -------------------------------------------------
# Genome quality assessment
# -------------------------------------------------
rm -rf "$RESULTS/quality/checkm2"
rm -rf "$RESULTS/quality/quast"
rm -rf "$RESULTS/quality/busco"
rm -rf "$RESULTS/quality/coverage"

# -------------------------------------------------
# Genome annotation
# -------------------------------------------------
rm -rf "$RESULTS/annotation/prokka"/*
rm -rf "$RESULTS/annotation/bakta"/*

# -------------------------------------------------
# Plassembler (KEEP SUMMARY + logs)
# -------------------------------------------------
find "$RESULTS/plasmids" -type f \
  ! -name "plassembler_summary.tsv" \
  ! -name "*.log" \
  -delete

# -------------------------------------------------
# Abricate
# -------------------------------------------------
rm -rf "$RESULTS/amr"/*

# -------------------------------------------------
# geNomad
# -------------------------------------------------
rm -rf "$RESULTS/prophage"/*

# -------------------------------------------------
# Generic heavy junk
# -------------------------------------------------
find "$RESULTS" -type f \( \
  -name "*.bam" -o \
  -name "*.bai" -o \
  -name "*.depth*" -o \
  -name "*.paf" -o \
  -name "*.html" \
\) -delete

echo "----------------------------------------------"
echo " Cleanup complete for:"
echo "  $PROJECT_DIR"
echo "----------------------------------------------"
