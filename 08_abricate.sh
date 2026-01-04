#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"
conda activate 07_abricate

# ===============================
# INPUT ARGUMENT
# ===============================
PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
  echo "Usage: 08_abricate.sh <PROJECT_DIR>"
  exit 1
fi

ASM="$PROJECT_DIR/results/assembly/03_hybrid/assembly.fasta"
PLASM="$PROJECT_DIR/results/plasmids/plassembler_plasmids.fasta"
OUT="$PROJECT_DIR/results/amr"

# -------------------------------
# Sanity checks
# -------------------------------
[[ -f "$ASM" ]]   || { echo "ERROR: Assembly FASTA not found: $ASM"; exit 1; }
[[ -f "$PLASM" ]] || { echo "ERROR: Plasmid FASTA not found: $PLASM"; exit 1; }

# clean old results
rm -rf "$OUT"
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
for db in "${DBS[@]}"; do
  abricate --db "$db" "$PLASM" > \
    "$OUT/plasmid_level/abricate_${db}_plasmid.tsv"
done

abricate --summary \
  "$OUT"/plasmid_level/abricate_*_plasmid.tsv > \
  "$OUT/plasmid_level/abricate_plasmid_summary.tsv"

echo "✅ Abricate completed successfully"
echo "Results:"
echo " - $OUT/assembly_level"
echo " - $OUT/plasmid_level"
