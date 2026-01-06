#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR=${1:-}

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: cleanup_project.sh <PROJECT_DIR>"
  exit 1
fi

RESULTS="$PROJECT_DIR/results"
FIGURES="$PROJECT_DIR/figures"

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

# QC
safe_rm_dir "$RESULTS/qc_before"
safe_rm_dir "$RESULTS/qc_after"

# Assembly (keep fasta)
safe_find_delete "$RESULTS/assembly" -type f ! -name "assembly.fasta"

# Quality
safe_rm_dir "$RESULTS/quality/checkm2"
safe_rm_dir "$RESULTS/quality/quast"
safe_rm_dir "$RESULTS/quality/busco"
safe_rm_dir "$RESULTS/quality/coverage"

# Annotation
safe_find_delete "$RESULTS/annotation/prokka" -type f ! -name "*.gff" ! -name "*.tsv"
safe_find_delete "$RESULTS/annotation/bakta"  -type f ! -name "*.gff" ! -name "*.tsv"

# Plassembler
safe_find_delete "$RESULTS/plasmids" -type f ! -name "*summary*.tsv" ! -name "*.log"

# Abricate
safe_find_delete "$RESULTS/amr" -type f ! -name "*summary*.tsv"

# geNomad
safe_find_delete "$RESULTS/prophage" \
  -type f ! \( -name "*summary*" -o -name "*.tsv" -o -name "*.json" \)

# Heavy junk (exclude prophage)
safe_find_delete "$RESULTS" -type f \
  ! -path "$RESULTS/prophage/*" \( \
    -name "*.bam" -o \
    -name "*.bai" -o \
    -name "*.depth*" -o \
    -name "*.paf" -o \
    -name "*.html" \
  \)

echo "----------------------------------------------"
echo " Cleanup complete (SAFE)"
echo " Results kept:"
echo "  - assembly.fasta"
echo "  - summary TSVs"
echo "  - figures/ (not touched)"
echo "----------------------------------------------"
echo "✅ Project cleanup completed safely."