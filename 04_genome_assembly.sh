#!/bin/bash
set -euo pipefail
shopt -s nullglob

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=${1:-}

if [[ -z "$RESULTS" ]]; then
  echo "Usage: 04_genome_assembly.sh <RESULTS_DIR>"
  exit 1
fi

SHORT_PROC="$RESULTS/processed_reads/short_reads"
LONG_PROC="$RESULTS/processed_reads/long_reads"
ASM_OUT="$RESULTS/assembly"

THREADS=14

mkdir -p \
  "$ASM_OUT/01_short_only" \
  "$ASM_OUT/02_long_only" \
  "$ASM_OUT/03_hybrid"

############################
# Detect sample name
############################
cd "$SHORT_PROC"
R1_FILES=(*_1.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE processed short-read sample"
  exit 1
fi

SAMPLE_NAME="${R1_FILES[0]%%_1.fastq.gz}"

R1="$SHORT_PROC/${SAMPLE_NAME}_1.fastq.gz"
R2="$SHORT_PROC/${SAMPLE_NAME}_2.fastq.gz"
LONG="$LONG_PROC/${SAMPLE_NAME}_long.fastq.gz"

############################
# Activate Unicycler
############################
conda activate 04_unicycler

############################
# Short-read only assembly
############################
unicycler \
  -1 "$R1" \
  -2 "$R2" \
  -o "$ASM_OUT/01_short_only" \
  -t "$THREADS"

############################
# Long-read only assembly
############################
if [[ -f "$LONG" ]]; then
  unicycler \
    -l "$LONG" \
    -o "$ASM_OUT/02_long_only" \
    -t "$THREADS"
else
  echo "⚠️ Long reads not found — skipping long-only assembly"
fi

############################
# Hybrid assembly
############################
if [[ -f "$LONG" ]]; then
  unicycler \
    -1 "$R1" \
    -2 "$R2" \
    -l "$LONG" \
    -o "$ASM_OUT/03_hybrid" \
    -t "$THREADS" \
    --verbosity 2 \
    --min_fasta_length 500
else
  echo "⚠️ Long reads not found — skipping hybrid assembly"
fi

echo "✅ Genome assembly complete."
echo "Sample: $SAMPLE_NAME"
echo "Results saved in: $ASM_OUT"
