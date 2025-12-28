#!/bin/bash
set -e

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"

# QC before processing
mkdir -p \
  "$BASE/02_qc_before_processing/short_reads" \
  "$BASE/02_qc_before_processing/long_reads"

# Processed reads
mkdir -p \
  "$BASE/03_processed_reads/short_reads" \
  "$BASE/03_processed_reads/long_reads"

# QC after processing
mkdir -p \
  "$BASE/04_qc_after_processing/short_reads" \
  "$BASE/04_qc_after_processing/long_reads"

# Genome assemblies
mkdir -p \
  "$BASE/05_genome_assembly/01_short_only" \
  "$BASE/05_genome_assembly/02_long_only" \
  "$BASE/05_genome_assembly/03_hybrid"

# Genome quality assessment
mkdir -p \
  "$BASE/06_genome_quality_assessment/checkm2/short_only" \
  "$BASE/06_genome_quality_assessment/checkm2/long_only" \
  "$BASE/06_genome_quality_assessment/checkm2/hybrid"

mkdir -p \
  "$BASE/06_genome_quality_assessment/quast/short_only" \
  "$BASE/06_genome_quality_assessment/quast/long_only" \
  "$BASE/06_genome_quality_assessment/quast/hybrid"

mkdir -p \
  "$BASE/06_genome_quality_assessment/busco/short_only" \
  "$BASE/06_genome_quality_assessment/busco/long_only" \
  "$BASE/06_genome_quality_assessment/busco/hybrid"

# Genome annotation
mkdir -p \
  "$BASE/07_genome_annotation/prokka/short_only" \
  "$BASE/07_genome_annotation/prokka/long_only" \
  "$BASE/07_genome_annotation/prokka/hybrid"

mkdir -p \
  "$BASE/07_genome_annotation/bakta/short_only" \
  "$BASE/07_genome_annotation/bakta/long_only" \
  "$BASE/07_genome_annotation/bakta/hybrid"

# Plasmid & MGE analyses
mkdir -p "$BASE/08_plassembler"

mkdir -p \
  "$BASE/09_abricate/assembly_level" \
  "$BASE/09_abricate/plasmid_level"

mkdir -p \
  "$BASE/10_genomad/assembly_level" \
  "$BASE/10_genomad/plasmid_level"

chmod +x 01_make_directories.sh

echo "Directory structure created successfully."
