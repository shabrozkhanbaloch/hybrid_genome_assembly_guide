#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENTS
# ===============================
RAW=$1
RESULTS=$2

if [ -z "$RAW" ] || [ -z "$RESULTS" ]; then
  echo "Usage: 02_qc_reads_before_processing.sh <RAW_DIR> <RESULTS_DIR>"
  exit 1
fi

RAW_SHORT="$RAW/short_reads"
RAW_LONG="$RAW/long_reads"

QC_SHORT="$RESULTS/qc_before/short_reads"
QC_LONG="$RESULTS/qc_before/long_reads"

mkdir -p "$QC_SHORT" "$QC_LONG"

############################
# Short-read QC (FastQC)
############################
conda activate 01_short_read_qc

fastqc \
  -t 14 \
  --extract \
  --svg \
  -o "$QC_SHORT" \
  "$RAW_SHORT"/*.fastq.gz

############################
# Long-read QC (NanoPlot)
############################
conda activate 03a_long_read_nanoplot

NanoPlot \
  --fastq "$RAW_LONG"/*.fastq.gz \
  --outdir "$QC_LONG" \
  --threads 14

############################
# MultiQC (short reads only)
############################
conda activate 02_multiqc
mkdir -p "$QC_SHORT/multiqc"

multiqc \
  "$QC_SHORT" \
  -o "$QC_SHORT/multiqc" \
  -p

echo "QC before processing (short + long reads) complete."
echo "Results saved in:"
echo "  Short reads QC: $QC_SHORT"
echo "  Long reads QC:  $QC_LONG"
