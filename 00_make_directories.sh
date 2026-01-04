#!/bin/bash
set -euo pipefail

PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
  echo "Usage: 00_make_directories.sh <PROJECT_DIR>"
  exit 1
fi

BASE="$PROJECT_DIR/results"

# ===============================
# QC before processing
# ===============================
mkdir -p \
  "$BASE/qc_before/short_reads" \
  "$BASE/qc_before/long_reads"

# ===============================
# Processed reads
# ===============================
mkdir -p \
  "$BASE/processed_reads/short_reads" \
  "$BASE/processed_reads/long_reads"

# ===============================
# QC after processing
# ===============================
mkdir -p \
  "$BASE/qc_after/short_reads" \
  "$BASE/qc_after/long_reads"

# ===============================
# Genome assemblies
# ===============================
mkdir -p \
  "$BASE/assembly/01_short_only" \
  "$BASE/assembly/02_long_only" \
  "$BASE/assembly/03_hybrid"

# ===============================
# Genome quality assessment
# ===============================
mkdir -p \
  "$BASE/quality/checkm2"/{short_only,long_only,hybrid} \
  "$BASE/quality/quast"/{01_short_only,02_long_only,03_hybrid} \
  "$BASE/quality/busco"/{short_only,long_only,hybrid} \
  "$BASE/quality/coverage"

# ===============================
# Genome annotation
# ===============================
mkdir -p \
  "$BASE/annotation/prokka"/{01_short_only,02_long_only,03_hybrid} \
  "$BASE/annotation/bakta"/{01_short_only,02_long_only,03_hybrid}

# ===============================
# Plasmids + AMR + Prophage
# ===============================
mkdir -p \
  "$BASE/plasmids" \
  "$BASE/amr"/{assembly_level,plasmid_level} \
  "$BASE/prophage"/{assembly_level,plasmid_level}

echo "✅ Project directory structure created:"
echo "   $PROJECT_DIR"
