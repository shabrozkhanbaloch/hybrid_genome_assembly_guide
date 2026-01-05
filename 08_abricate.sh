#!/bin/bash
set -euo pipefail
shopt -s nullglob

eval "$(conda shell.bash hook)"
conda activate 07_abricate

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=${1:-}

if [[ -z "$RESULTS" ]]; then
  echo "Usage: 08_abricate.sh <RESULTS_DIR>"
  exit 1
fi

ASM="$RESULTS/assembly/03_hybrid/assembly.fasta"
PLASM_DIR="$RESULTS/plasmids"
OUT="$RESULTS/amr"

# -------------------------------
# Sanity checks
# -------------------------------
[[ -f "$ASM" ]] || { echo "❌ Assembly FASTA not found: $ASM"; exit 1; }

PLASM_FILES=("$PLASM_DIR"/*.fasta)

if [[ ${#PLASM_FILES[@]} -lt 1 ]]; then
  echo "❌ No plasmid FASTA found in $PLASM_DIR"
  exit 1
fi

# safe clean
mkdir -p "$OUT"
rm -f "$OUT"/*.tsv

mkdir -p "$OUT/assembly_level" "$OUT/plasmid_level"

DBS=(ncbi resfinder card vfdb)

# -------- assembly level --------
for db in "${DBS[@]}"; do
  abricate --db "$db" "$ASM" > \
    "$OUT/assembly_level/abricate_${db}_assembly.tsv"
done

abricate --summary \
  "$OUT"/assembly_level/abricate_*_assembly.tsv > \
  "$OUT/assembly_level/abricate_assembly_summary.tsv"

# -------- plasmid level --------
for fasta in "${PLASM_FILES[@]}"; do
  base=$(basename "$fasta" .fasta)
  for db in "${DBS[@]}"; do
    abricate --db "$db" "$fasta" > \
      "$OUT/plasmid_level/abricate_${db}_${base}.tsv"
  done
done

abricate --summary \
  "$OUT"/plasmid_level/abricate_*.tsv > \
  "$OUT/plasmid_level/abricate_plasmid_summary.tsv"

echo "✅ Abricate completed successfully"
echo "Results:"
echo " - $OUT/assembly_level"
echo " - $OUT/plasmid_level"
