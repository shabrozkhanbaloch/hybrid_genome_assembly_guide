#!/bin/bash
set -euo pipefail

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=$1

if [ -z "$RESULTS" ]; then
  echo "Usage: 01_make_directories.sh <RESULTS_DIR>"
  echo "Example: 01_make_directories.sh /data/wgs_assembly/PROJECTS/paper_02"
  exit 1
fi

BASE="$RESULTS"

echo "📁 Creating directory structure in: $BASE"

# ===============================
# ASSEMBLIES
# ===============================
mkdir -p \
  "$BASE/assembly/01_short_only" \
  "$BASE/assembly/02_long_only" \
  "$BASE/assembly/03_hybrid"

# ===============================
# QUALITY ASSESSMENT
# ===============================
mkdir -p \
  "$BASE/results/quality/checkm2"/{short_only,long_only,hybrid} \
  "$BASE/results/quality/quast"/{01_short_only,02_long_only,03_hybrid} \
  "$BASE/results/quality/busco"/{short_only,long_only,hybrid} \
  "$BASE/results/quality/coverage"

# ===============================
# ANNOTATION
# ===============================
mkdir -p \
  "$BASE/results/annotation/prokka"/{01_short_only,02_long_only,03_hybrid} \
  "$BASE/results/annotation/bakta"/{01_short_only,02_long_only,03_hybrid}

# ===============================
# PLASMIDS
# ===============================
mkdir -p \
  "$BASE/results/plasmids"/{plassembler,unicycler,flye}

# ===============================
# AMR
# ===============================
mkdir -p \
  "$BASE/results/amr"/{assembly_level,plasmid_level}

# ===============================
# PHAGE / MGE (geNomad)
# ===============================
mkdir -p \
  "$BASE/results/prophage"/{assembly_level,plasmid_level}

# ===============================
# FIGURES
# ===============================
mkdir -p "$BASE/figures"

echo "✅ Directory structure created successfully."
