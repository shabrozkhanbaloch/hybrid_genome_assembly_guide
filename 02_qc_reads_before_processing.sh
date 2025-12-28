#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"

RAW_SHORT="$BASE/01_raw_reads/short_reads"
RAW_LONG="$BASE/01_raw_reads/long_reads"

QC_SHORT="$BASE/02_qc_before_processing/short_reads"
QC_LONG="$BASE/02_qc_before_processing/long_reads"

mkdir -p "$QC_SHORT" "$QC_LONG"

############################
# Short-read QC (FastQC)
############################
conda activate 01_short_read_qc

fastqc \
  -t 12 \
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
  --threads 12

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