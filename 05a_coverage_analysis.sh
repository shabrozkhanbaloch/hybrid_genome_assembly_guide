#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"
conda activate 04_unicycler   # minimap2 + samtools

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=$1

if [ -z "$RESULTS" ]; then
  echo "Usage: 05a_coverage_analysis.sh <RESULTS_DIR>"
  exit 1
fi

# ===============================
# Paths (project-aware)
# ===============================
ASM="$RESULTS/assembly"
PROC="$RESULTS/processed_reads"
OUT="$RESULTS/quality/coverage"

SHORT_ASM="$ASM/01_short_only/assembly.fasta"
HYBRID_ASM="$ASM/03_hybrid/assembly.fasta"

SR1="$PROC/short_reads/processed_1.fastq.gz"
SR2="$PROC/short_reads/processed_2.fastq.gz"
LR="$PROC/long_reads/processed_long.fastq.gz"

mkdir -p \
  "$OUT/short_reads/short_vs_short" \
  "$OUT/short_reads/short_vs_hybrid" \
  "$OUT/long_reads/long_vs_hybrid"

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

echo "Coverage analysis complete."
echo "Results saved in: $OUT"
