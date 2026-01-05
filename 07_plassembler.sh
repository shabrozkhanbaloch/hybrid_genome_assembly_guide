#!/bin/bash
set -euo pipefail
shopt -s nullglob

########################################
# Plassembler – hybrid plasmid assembly
########################################

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=${1:-}

if [[ -z "$RESULTS" ]]; then
  echo "Usage: 07_plassembler.sh <RESULTS_DIR>"
  exit 1
fi

PROC="$RESULTS/processed_reads"
OUT="$RESULTS/plasmids"
DB="/data/databases_important/plassembler_db"

SHORT_PROC="$PROC/short_reads"
LONG_PROC="$PROC/long_reads"

mkdir -p "$OUT"

########################################
# Detect processed short reads
########################################
R1_FILES=("$SHORT_PROC"/*_1.fastq.gz)
R2_FILES=("$SHORT_PROC"/*_2.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 || ${#R2_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE processed short-read pair"
  exit 1
fi

SHORT1="${R1_FILES[0]}"
SHORT2="${R2_FILES[0]}"

########################################
# Detect processed long reads
########################################
LR_FILES=("$LONG_PROC"/*_long.fastq.gz)

if [[ ${#LR_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE processed long-read file"
  exit 1
fi

LONG="${LR_FILES[0]}"

########################################
# Sanity checks
########################################
for f in "$SHORT1" "$SHORT2" "$LONG"; do
  [[ -f "$f" ]] || { echo "❌ ERROR: Missing input file $f"; exit 1; }
done

[[ -d "$DB" ]] || { echo "❌ ERROR: Missing Plassembler DB $DB"; exit 1; }

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
  --threads 14 \
  --force

########################################
# Final message
########################################
echo "✅ Plassembler plasmid reconstruction complete."
echo "Results saved in: $OUT"
echo "Key outputs:"
echo "  - $OUT/final_plasmids/"
echo "  - $OUT/plasmid_report.tsv"
