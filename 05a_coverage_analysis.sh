#!/bin/bash
set -euo pipefail
shopt -s nullglob

eval "$(conda shell.bash hook)"
conda activate 04_unicycler   # minimap2 + samtools

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=${1:-}

if [[ -z "$RESULTS" ]]; then
  echo "Usage: 05a_coverage_analysis.sh <RESULTS_DIR>"
  exit 1
fi

# ===============================
# Paths
# ===============================
ASM="$RESULTS/assembly"
PROC="$RESULTS/processed_reads"
OUT="$RESULTS/quality/coverage"

SHORT_ASM="$ASM/01_short_only/assembly.fasta"
HYBRID_ASM="$ASM/03_hybrid/assembly.fasta"

SHORT_PROC="$PROC/short_reads"
LONG_PROC="$PROC/long_reads"

mkdir -p \
  "$OUT/short_reads/short_vs_short" \
  "$OUT/short_reads/short_vs_hybrid" \
  "$OUT/long_reads/long_vs_hybrid"

# ===============================
# Detect processed short reads
# ===============================
R1_FILES=("$SHORT_PROC"/*_1.fastq.gz)
R2_FILES=("$SHORT_PROC"/*_2.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 || ${#R2_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE processed short-read pair"
  exit 1
fi

SR1="${R1_FILES[0]}"
SR2="${R2_FILES[0]}"

# ===============================
# Detect processed long reads
# ===============================
LR_FILES=("$LONG_PROC"/*_long.fastq.gz)

if [[ ${#LR_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE processed long-read file"
  exit 1
fi

LR="${LR_FILES[0]}"

# ===============================
# Sanity checks
# ===============================
[[ -f "$SHORT_ASM" ]] || { echo "❌ Missing short-read assembly"; exit 1; }
[[ -f "$HYBRID_ASM" ]] || { echo "❌ Missing hybrid assembly"; exit 1; }

############################
# 1. Short reads → Short-only
############################
minimap2 -ax sr "$SHORT_ASM" "$SR1" "$SR2" | \
  samtools sort -o "$OUT/short_reads/short_vs_short/aln.bam"

samtools index "$OUT/short_reads/short_vs_short/aln.bam"

samtools depth "$OUT/short_reads/short_vs_short/aln.bam" > \
  "$OUT/short_reads/short_vs_short/depth.txt"

############################
# 2. Short reads → Hybrid
############################
minimap2 -ax sr "$HYBRID_ASM" "$SR1" "$SR2" | \
  samtools sort -o "$OUT/short_reads/short_vs_hybrid/aln.bam"

samtools index "$OUT/short_reads/short_vs_hybrid/aln.bam"

samtools depth "$OUT/short_reads/short_vs_hybrid/aln.bam" > \
  "$OUT/short_reads/short_vs_hybrid/depth.txt"

############################
# 3. Long reads → Hybrid
############################
minimap2 -ax map-ont "$HYBRID_ASM" "$LR" | \
  samtools sort -o "$OUT/long_reads/long_vs_hybrid/aln.bam"

samtools index "$OUT/long_reads/long_vs_hybrid/aln.bam"

samtools depth "$OUT/long_reads/long_vs_hybrid/aln.bam" > \
  "$OUT/long_reads/long_vs_hybrid/depth.txt"

echo "✅ Coverage analysis complete."
echo "Results saved in: $OUT"
