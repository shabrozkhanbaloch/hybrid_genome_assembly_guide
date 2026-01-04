#!/bin/bash
set -euo pipefail

# ===============================
# INPUT ARGUMENT
# ===============================
PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
  echo "Usage: ./run_pipeline.sh /full/path/to/PROJECT_DIR"
  exit 1
fi

# ===============================
# PIPELINE BASE (CODE ONLY)
# ===============================
PIPELINE_BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"

# ===============================
# PROJECT PATHS
# ===============================
RAW="$PROJECT_DIR/data/raw_reads"
RESULTS="$PROJECT_DIR/results"
FIGURES="$PROJECT_DIR/figures"

echo "=========================================="
echo " Hybrid Genome Assembly Pipeline STARTED"
echo " Project: $PROJECT_DIR"
echo "=========================================="

########################################
# 1. Setup raw reads
########################################
echo "[1/8] Setting up raw reads..."
bash "$PIPELINE_BASE/01_setup_raw_reads.sh" "$RAW"

########################################
# 2. QC before processing
########################################
echo "[2/8] QC before processing..."
bash "$PIPELINE_BASE/02_qc_reads_before_processing.sh" "$RAW" "$RESULTS"

########################################
# 3. Read processing
########################################
echo "[3/8] Processing reads..."
bash "$PIPELINE_BASE/03_process_reads.sh" "$RAW" "$RESULTS"

########################################
# 4. Genome assembly
########################################
echo "[4/8] Genome assembly (short / long / hybrid)..."
bash "$PIPELINE_BASE/04_genome_assembly.sh" "$RESULTS"

########################################
# 5. Genome quality assessment
########################################
echo "[5/8] Genome quality assessment..."
bash "$PIPELINE_BASE/05_genome_quality_assessment.sh" "$RESULTS"

echo "[5a] Coverage depth analysis..."
bash "$PIPELINE_BASE/05a_coverage_analysis.sh" "$RESULTS"

########################################
# 6. Genome annotation
########################################
echo "[6/8] Genome annotation (Prokka + Bakta)..."
bash "$PIPELINE_BASE/06_genome_annotation.sh" "$RESULTS"

########################################
# 7. Plasmid reconstruction
########################################
echo "[7/8] Plasmid reconstruction (Plassembler)..."
bash "$PIPELINE_BASE/07_plassembler.sh" "$RESULTS"

########################################
# 8. AMR + viral analysis
########################################
echo "[8/8] AMR detection (Abricate) + Viral detection (geNomad)..."
bash "$PIPELINE_BASE/08_abricate.sh" "$RESULTS"
bash "$PIPELINE_BASE/09_genomad.sh" "$RESULTS"

########################################
# DONE
########################################
echo "=========================================="
echo " Hybrid Genome Assembly Pipeline COMPLETE"
echo "=========================================="

echo "Outputs stored in:"
echo " - Results:  $RESULTS"
echo " - Figures:  $FIGURES"
echo "✅ Pipeline completed successfully."