#!/bin/bash
set -euo pipefail

########################################
# Plassembler – hybrid plasmid assembly
########################################

eval "$(conda shell.bash hook)"

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"

SHORT1="$BASE/03_processed_reads/short_reads/processed_1.fastq.gz"
SHORT2="$BASE/03_processed_reads/short_reads/processed_2.fastq.gz"
LONG="$BASE/03_processed_reads/long_reads/processed_long.fastq.gz"

OUT="$BASE/08_plassembler"
DB="/data/databases_important/plassembler_db"

mkdir -p "$OUT"

########################################
# Sanity checks
########################################
for f in "$SHORT1" "$SHORT2" "$LONG"; do
  [[ -f "$f" ]] || { echo "ERROR: Missing input file $f"; exit 1; }
done

[[ -d "$DB" ]] || { echo "ERROR: Missing Plassembler DB $DB"; exit 1; }

########################################
# Run Plassembler
########################################
conda activate 06_plassembler

plassembler run \
  --short_one "$SHORT1" \
  --short_two "$SHORT2" \
  --longreads "$LONG" \
  --database "$DB" \
  --min_length 1000 \
  --min_quality 9 \
  --no_chromosome \
  --outdir "$OUT" \
  --threads 10 \
  --force

########################################
# Final message
########################################
echo "Plassembler plasmid reconstruction complete."
echo "Results saved in: $OUT"
echo "Key outputs:"
echo "  - $OUT/final_plasmids/        (plasmid FASTAs)"
echo "  - $OUT/plasmid_report.tsv     (classification + metadata)"
