#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"
conda activate 07_abricate

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=$1

if [ -z "$RESULTS" ]; then
  echo "Usage: 08_abricate.sh <RESULTS_DIR>"
  exit 1
fi

ASM="$RESULTS/assembly/03_hybrid/assembly.fasta"
PLASM="$RESULTS/plasmids/plassembler_plasmids.fasta"
OUT="$RESULTS/amr"

# clean old results
rm -rf "$OUT"
mkdir -p "$OUT/assembly_level" "$OUT/plasmid_level"

DBS=(ncbi resfinder card vfdb)

# -------- assembly level --------
for db in "${DBS[@]}"; do
  abricate --db "$db" "$ASM" > \
    "$OUT/assembly_level/abricate_${db}_assembly.tsv"
done

abricate --summary "$OUT"/assembly_level/abricate_*_assembly.tsv > \
  "$OUT/assembly_level/abricate_assembly_summary.tsv"

# -------- plasmid level --------
for db in "${DBS[@]}"; do
  abricate --db "$db" "$PLASM" > \
    "$OUT/plasmid_level/abricate_${db}_plasmid.tsv"
done

abricate --summary "$OUT"/plasmid_level/abricate_*_plasmid.tsv > \
  "$OUT/plasmid_level/abricate_plasmid_summary.tsv"

echo "Abricate completed successfully."
echo "Results:"
echo "  - $OUT/assembly_level"
echo "  - $OUT/plasmid_level"
