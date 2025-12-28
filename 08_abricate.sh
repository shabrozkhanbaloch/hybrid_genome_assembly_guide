#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"
conda activate 07_abricate

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"
ASM="$BASE/05_genome_assembly/03_hybrid/assembly.fasta"
PLASM="$BASE/08_plassembler/plassembler_plasmids.fasta"
OUT="$BASE/09_abricate"

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
