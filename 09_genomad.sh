#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"
conda activate 08_genomad

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"
ASM="$BASE/05_genome_assembly/03_hybrid/assembly.fasta"
PLASM="$BASE/08_plassembler/plassembler_plasmids.fasta"
DB="/data/databases_important/genomad_db"
OUT="$BASE/10_genomad"

# clean old results
rm -rf "$OUT"
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
genomad end-to-end \
  --cleanup \
  --splits 8 \
  "$PLASM" \
  "$OUT/plasmid_level" \
  "$DB" \
  --threads 14

echo "geNomad completed successfully."
echo "Results:"
echo "  - $OUT/assembly_level"
echo "  - $OUT/plasmid_level"
