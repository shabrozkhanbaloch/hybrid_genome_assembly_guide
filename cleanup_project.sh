#!/usr/bin/env bash
set -euo pipefail

# ===============================
# INPUT ARGUMENT
# ===============================
PROJECT_DIR=${1:-}

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: cleanup_project.sh <PROJECT_DIR>"
  exit 1
fi

RESULTS="$PROJECT_DIR/results"
FIGURES="$PROJECT_DIR/figures"

# ===============================
# HARD SAFETY GUARDS
# ===============================
[[ -d "$RESULTS" ]] || { echo "❌ RESULTS dir not found: $RESULTS"; exit 1; }
[[ "$RESULTS" == */results ]] || {
  echo "❌ SAFETY CHECK FAILED: refusing to clean $RESULTS"
  exit 1
}

echo "=============================================="
echo " Project cleanup (SAFE MODE)"
echo " Target: $PROJECT_DIR"
echo "=============================================="

safe_rm_dir () {
  [[ -d "$1" ]] && rm -rf "$1"/* || true
}

safe_find_delete () {
  [[ -d "$1" ]] && find "$1" "${@:2}" -delete || true
}

# -------------------------------------------------
# QC outputs
# -------------------------------------------------
safe_rm_dir "$RESULTS/qc_before"
safe_rm_dir "$RESULTS/qc_after"

# -------------------------------------------------
# Genome assembly
# KEEP: assembly.fasta
# -------------------------------------------------
safe_find_delete "$RESULTS/assembly" -type f ! -name "assembly.fasta"

# -------------------------------------------------
# Genome quality assessment
# -------------------------------------------------
rm -rf "$RESULTS/quality/checkm2" \
       "$RESULTS/quality/quast" \
       "$RESULTS/quality/busco" \
       "$RESULTS/quality/coverage" 2>/dev/null || true

# -------------------------------------------------
# Genome annotation
# -------------------------------------------------
safe_find_delete "$RESULTS/annotation/prokka" \
  -type f ! -name "*.gff" ! -name "*.tsv"

safe_find_delete "$RESULTS/annotation/bakta" \
  -type f ! -name "*.gff" ! -name "*.tsv"

# -------------------------------------------------
# Plassembler
# -------------------------------------------------
safe_find_delete "$RESULTS/plasmids" \
  -type f ! -name "*summary*.tsv" ! -name "*.log"

# -------------------------------------------------
# Abricate
# -------------------------------------------------
safe_find_delete "$RESULTS/amr" \
  -type f ! -name "*summary*.tsv"

# -------------------------------------------------
# geNomad
# -------------------------------------------------
safe_find_delete "$RESULTS/prophage" \
  -type f ! -name "*summary*"

# -------------------------------------------------
# Generic heavy junk
# -------------------------------------------------
safe_find_delete "$RESULTS" -type f \( \
  -name "*.bam" -o \
  -name "*.bai" -o \
  -name "*.depth*" -o \
  -name "*.paf" -o \
  -name "*.html" -o \
  -name "*.json" \
\)

echo "----------------------------------------------"
echo " Cleanup complete (SAFE)"
echo " Results kept:"
echo "  - assembly.fasta"
echo "  - summary TSVs"
echo "  - figures/"
echo "----------------------------------------------"
