#!/bin/bash
set -euo pipefail
shopt -s nullglob

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENTS
# ===============================
RAW=${1:-}
RESULTS=${2:-}

if [[ -z "$RAW" || -z "$RESULTS" ]]; then
  echo "Usage: 03_process_reads.sh <RAW_DIR> <RESULTS_DIR>"
  exit 1
fi

RAW_SHORT="$RAW/short_reads"
RAW_LONG="$RAW/long_reads"

PROC_SHORT="$RESULTS/processed_reads/short_reads"
PROC_LONG="$RESULTS/processed_reads/long_reads"

QC_SHORT="$RESULTS/qc_after/short_reads"
QC_LONG="$RESULTS/qc_after/long_reads"

mkdir -p "$PROC_SHORT" "$PROC_LONG" "$QC_SHORT" "$QC_LONG"

THREADS=14

############################
# Detect sample name
############################
cd "$RAW_SHORT"
R1_FILES=(*_1.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE short-read sample"
  exit 1
fi

SAMPLE_NAME="${R1_FILES[0]%%_1.fastq.gz}"

############################
# Short reads processing (fastp)
############################
conda activate 01_short_read_qc

fastp \
  -i "$RAW_SHORT/${SAMPLE_NAME}_1.fastq.gz" \
  -I "$RAW_SHORT/${SAMPLE_NAME}_2.fastq.gz" \
  -o "$PROC_SHORT/${SAMPLE_NAME}_1.fastq.gz" \
  -O "$PROC_SHORT/${SAMPLE_NAME}_2.fastq.gz" \
  -q 25 \
  -w "$THREADS" \
  -h "$QC_SHORT/fastp_report.html" \
  -j "$QC_SHORT/fastp_report.json"

############################
# Long reads processing (NanoFilt)
############################
cd "$RAW_LONG"
LONG_FILES=(*.fastq.gz)

if [[ ${#LONG_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE long-read FASTQ file"
  exit 1
fi

conda activate 03b_long_read_nanofilt

zcat "${LONG_FILES[0]}" | \
  NanoFilt -q 8 --length 1000 --headcrop 50 | \
  gzip > "$PROC_LONG/${SAMPLE_NAME}_long.fastq.gz"

############################
# QC after processing (NanoPlot)
############################
conda activate 03a_long_read_nanoplot

NanoPlot \
  --fastq "$PROC_LONG/${SAMPLE_NAME}_long.fastq.gz" \
  --outdir "$QC_LONG" \
  --threads "$THREADS"

echo "✅ Read processing (short + long) complete."
echo "Processed reads saved in:"
echo "  Short reads: $PROC_SHORT"
echo "  Long reads:  $PROC_LONG"
