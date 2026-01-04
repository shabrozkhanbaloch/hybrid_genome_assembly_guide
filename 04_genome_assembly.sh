#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=$1

if [ -z "$RESULTS" ]; then
  echo "Usage: 04_genome_assembly.sh <RESULTS_DIR>"
  exit 1
fi

SHORT_PROC="$RESULTS/processed_reads/short_reads"
LONG_PROC="$RESULTS/processed_reads/long_reads"
ASM_OUT="$RESULTS/assembly"

mkdir -p \
  "$ASM_OUT/01_short_only" \
  "$ASM_OUT/02_long_only" \
  "$ASM_OUT/03_hybrid"

conda activate 04_unicycler

############################
# Short-read only assembly
############################
unicycler \
  -1 "$SHORT_PROC"/processed_1.fastq.gz \
  -2 "$SHORT_PROC"/processed_2.fastq.gz \
  -o "$ASM_OUT/01_short_only" \
  -t 14

############################
# Long-read only assembly
############################
unicycler \
  -l "$LONG_PROC"/processed_long.fastq.gz \
  -o "$ASM_OUT/02_long_only" \
  -t 14

############################
# Hybrid assembly
############################
unicycler \
  -1 "$SHORT_PROC"/processed_1.fastq.gz \
  -2 "$SHORT_PROC"/processed_2.fastq.gz \
  -l "$LONG_PROC"/processed_long.fastq.gz \
  -o "$ASM_OUT/03_hybrid" \
  -t 14 \
  --verbosity 2 \
  --min_fasta_length 500

echo "Genome assembly (short-only, long-only, hybrid) complete."
echo "Results saved in: $ASM_OUT"
echo "  Short-read only assembly: $ASM_OUT/01_short_only"
echo "  Long-read only assembly:  $ASM_OUT/02_long_only"
echo "  Hybrid assembly:          $ASM_OUT/03_hybrid"
