#!/bin/bash
set -euo pipefail

########################################
# Plassembler – hybrid plasmid assembly
########################################

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=$1

if [ -z "$RESULTS" ]; then
  echo "Usage: 07_plassembler.sh <RESULTS_DIR>"
  exit 1
fi

PROC="$RESULTS/processed_reads"

SHORT1="$PROC/short_reads/processed_1.fastq.gz"
SHORT2="$PROC/short_reads/processed_2.fastq.gz"
LONG="$PROC/long_reads/processed_long.fastq.gz"

OUT="$RESULTS/plasmids"
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
echo "  - $OUT/final_plasmids/"
echo "  - $OUT/plasmid_report.tsv"
