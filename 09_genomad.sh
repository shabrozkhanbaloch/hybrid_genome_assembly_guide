#!/bin/bash
set -euo pipefail
shopt -s nullglob

eval "$(conda shell.bash hook)"
conda activate 08_genomad

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=${1:-}

if [[ -z "$RESULTS" ]]; then
  echo "Usage: 09_genomad.sh <RESULTS_DIR>"
  exit 1
fi

ASM="$RESULTS/assembly/03_hybrid/assembly.fasta"
PLASM_DIR="$RESULTS/plasmids"
DB="/data/databases_important/genomad_db"
OUT="$RESULTS/prophage"

############################
# Sanity checks
############################
[[ -f "$ASM" ]] || { echo "❌ Assembly FASTA not found: $ASM"; exit 1; }
[[ -d "$DB" ]]  || { echo "❌ geNomad DB not found: $DB"; exit 1; }

PLASM_FILES=("$PLASM_DIR"/*.fasta)

if [[ ${#PLASM_FILES[@]} -lt 1 ]]; then
  echo "❌ No plasmid FASTA found in $PLASM_DIR"
  exit 1
fi

############################
# Safe output dirs
############################
mkdir -p "$OUT/assembly_level" "$OUT/plasmid_level"

############################
# Assembly-level geNomad
############################
genomad end-to-end \
  --cleanup \
  --splits 8 \
  "$ASM" \
  "$OUT/assembly_level" \
  "$DB" \
  --threads 14

############################
# Plasmid-level geNomad
############################
for fasta in "${PLASM_FILES[@]}"; do
  base=$(basename "$fasta" .fasta)

  genomad end-to-end \
    --cleanup \
    --splits 8 \
    "$fasta" \
    "$OUT/plasmid_level/$base" \
    "$DB" \
    --threads 14
done

echo "✅ geNomad completed successfully."
echo "Results:"
echo "  - $OUT/assembly_level"
echo "  - $OUT/plasmid_level"
