#!/bin/bash
set -euo pipefail

PROJECT_DIR=${1:-}

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: 00_make_directories.sh <PROJECT_DIR>"
  exit 1
fi

# -------------------------------
# SAFETY GUARD
# -------------------------------
[[ "$PROJECT_DIR" == */PROJECTS/* ]] || {
  echo "❌ SAFETY CHECK FAILED: PROJECT_DIR must be under PROJECTS/"
  exit 1
}

PROJECT_NAME=$(basename "$PROJECT_DIR")
PROJECT_ID=$(echo "$PROJECT_NAME" | grep -oE '[0-9]+$')

if [[ -z "$PROJECT_ID" ]]; then
  echo "❌ Could not extract project ID (expected paper_01, paper_02 …)"
  exit 1
fi

SEQ_BASE="/data/sequencing_data/project_${PROJECT_ID}"

BASE="$PROJECT_DIR/results"

mkdir -p \
  "$PROJECT_DIR/data" \
  "$PROJECT_DIR/figures"

# ===============================
# AUTO-SYMLINK SEQUENCING DATA
# ===============================
if [[ -d "$SEQ_BASE/short_reads" ]]; then
  ln -sfn "$SEQ_BASE/short_reads" "$PROJECT_DIR/data/short_reads"
  echo "🔗 short_reads → $SEQ_BASE/short_reads"
else
  echo "⚠️ short_reads not found: $SEQ_BASE/short_reads"
fi

if [[ -d "$SEQ_BASE/long_reads" ]]; then
  ln -sfn "$SEQ_BASE/long_reads" "$PROJECT_DIR/data/long_reads"
  echo "🔗 long_reads → $SEQ_BASE/long_reads"
else
  echo "⚠️ long_reads not found: $SEQ_BASE/long_reads"
fi

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
  "$BASE/quality/busco" \
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

echo "✅ Project directory structure + symlinks created:"
echo "   $PROJECT_DIR"
