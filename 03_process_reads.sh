#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"

RAW_SHORT="$BASE/01_raw_reads/short_reads"
RAW_LONG="$BASE/01_raw_reads/long_reads"

PROC_SHORT="$BASE/03_processed_reads/short_reads"
PROC_LONG="$BASE/03_processed_reads/long_reads"

QC_SHORT="$BASE/04_qc_after_processing/short_reads"
QC_LONG="$BASE/04_qc_after_processing/long_reads"

mkdir -p "$PROC_SHORT" "$PROC_LONG" "$QC_SHORT" "$QC_LONG"

############################
# Short reads processing (fastp)
############################
conda activate 01_short_read_qc

fastp \
  -i "$RAW_SHORT"/*_1.fastq.gz \
  -I "$RAW_SHORT"/*_2.fastq.gz \
  -o "$PROC_SHORT"/processed_1.fastq.gz \
  -O "$PROC_SHORT"/processed_2.fastq.gz \
  -q 25 \
  -w 14 \
  -h "$QC_SHORT"/fastp_report.html \
  -j "$QC_SHORT"/fastp_report.json

############################
# Long reads processing (NanoFilt)
############################
conda activate 03b_long_read_nanofilt

zcat "$RAW_LONG"/*.fastq.gz | \
  NanoFilt -q 8 --length 1000 --headcrop 50 | \
  gzip > "$PROC_LONG"/processed_long.fastq.gz

############################
# QC after processing (NanoPlot)
############################
conda activate 03a_long_read_nanoplot

NanoPlot \
  --fastq "$PROC_LONG"/processed_long.fastq.gz \
  --outdir "$QC_LONG" \
  --threads 14

echo "Read processing (short + long) complete."
echo "Processed reads saved in:"
echo "  Short reads: $PROC_SHORT"
echo "  Long reads:  $PROC_LONG"
