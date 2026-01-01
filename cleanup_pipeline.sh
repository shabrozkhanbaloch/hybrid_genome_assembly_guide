#!/usr/bin/env bash
set -euo pipefail

BASE="$(pwd)"

echo "=============================================="
echo " Full pipeline cleanup (QC → Genomad)"
echo "=============================================="

# -------------------------------------------------
# 02–04 QC outputs
# -------------------------------------------------
rm -rf $BASE/02_qc_before_processing/*
rm -rf $BASE/04_qc_after_processing/*

# -------------------------------------------------
# 05 Genome assembly (KEEP FASTA ONLY)
# -------------------------------------------------
find $BASE/05_genome_assembly -type f ! -name "assembly.fasta" -delete

# -------------------------------------------------
# 06 Genome quality assessment (ALL GENERATED)
# -------------------------------------------------
rm -rf $BASE/06_genome_quality_assessment/checkm2
rm -rf $BASE/06_genome_quality_assessment/quast
rm -rf $BASE/06_genome_quality_assessment/busco
rm -rf $BASE/06_genome_quality_assessment/coverage
rm -rf $BASE/06_genome_quality_assessment/dotplots
rm -rf $BASE/06_genome_quality_assessment/gc_bias
rm -rf $BASE/06_genome_quality_assessment/plasmid_copy_number
rm -f  $BASE/06_genome_quality_assessment/*.html

# -------------------------------------------------
# 07 Genome annotation (Prokka / Bakta outputs)
# -------------------------------------------------
rm -rf $BASE/07_genome_annotation/prokka/*
rm -rf $BASE/07_genome_annotation/bakta/*

# -------------------------------------------------
# 08 Plassembler (KEEP SUMMARY ONLY)
# -------------------------------------------------
find $BASE/08_plassembler -type f \
  ! -name "plassembler_summary.tsv" \
  ! -name "*.log" \
  -delete

# -------------------------------------------------
# 09 Abricate
# -------------------------------------------------
rm -rf $BASE/09_abricate/*

# -------------------------------------------------
# 10 GeNomad
# -------------------------------------------------
rm -rf $BASE/10_genomad/*

# -------------------------------------------------
# Logs / temp / junk
# -------------------------------------------------
find $BASE -type f \( \
  -name "*.bam" -o \
  -name "*.bai" -o \
  -name "*.depth*" -o \
  -name "*.paf" -o \
  -name "*.html" -o \
  -name "*.tmp" -o \
  -name ".Rhistory" \
\) -delete

# -------------------------------------------------
# Fastp reports (generated)
# -------------------------------------------------
rm -f $BASE/fastp.html $BASE/fastp.json

echo "----------------------------------------------"
echo " Cleanup complete."
echo " Repo now contains ONLY:"
echo "  - scripts"
echo "  - directory structure"
echo "  - lightweight summaries"
echo "----------------------------------------------"
