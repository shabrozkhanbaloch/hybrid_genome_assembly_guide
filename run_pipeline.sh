#!/bin/bash
set -euo pipefail

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"

echo "=========================================="
echo " Hybrid Genome Assembly Pipeline STARTED"
echo "=========================================="

########################################
# 1. Setup raw reads
########################################
echo "[1/8] Setting up raw reads..."
bash "$BASE/01_setup_raw_reads.sh"

########################################
# 2. QC before processing
########################################
echo "[2/8] QC before processing..."
bash "$BASE/02_qc_reads_before_processing.sh"

########################################
# 3. Read processing
########################################
echo "[3/8] Processing reads..."
bash "$BASE/03_process_reads.sh"

########################################
# 4. Genome assembly
########################################
echo "[4/8] Genome assembly (short / long / hybrid)..."
bash "$BASE/04_genome_assembly.sh"

########################################
# 5. Genome quality assessment
########################################
echo "[5/8] Genome quality assessment..."
bash "$BASE/05_genome_quality_assessment.sh"

########################################
# 6. Genome annotation
########################################
echo "[6/8] Genome annotation (Prokka + Bakta)..."
bash "$BASE/06_genome_annotation.sh"

########################################
# 7. Plasmid reconstruction
########################################
echo "[7/8] Plasmid reconstruction (Plassembler)..."
bash "$BASE/07_plassembler.sh"

########################################
# 8. AMR + viral analysis
########################################
echo "[8/8] AMR detection (Abricate) + Viral detection (geNomad)..."
bash "$BASE/08_abricate.sh"
bash "$BASE/09_genomad.sh"

########################################
# DONE
########################################
echo "=========================================="
echo " Hybrid Genome Assembly Pipeline COMPLETE"
echo "=========================================="

echo "Key outputs:"
echo " - Hybrid assembly:      05_genome_assembly/03_hybrid/assembly.fasta"
echo " - Plasmids:             08_plassembler/plassembler_plasmids.fasta"
echo " - AMR (genome):         09_abricate/assembly_level/"
echo " - AMR (plasmids):       09_abricate/plasmid_level/"
echo " - Prophages / viruses:  10_genomad/"
