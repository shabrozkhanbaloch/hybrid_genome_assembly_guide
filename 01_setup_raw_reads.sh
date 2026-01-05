#!/bin/bash
set -euo pipefail
shopt -s nullglob

# ===============================
# INPUT ARGUMENT
# ===============================
DATA_DIR=${1:-}

if [[ -z "$DATA_DIR" ]]; then
  echo "Usage: 01_setup_raw_reads.sh <DATA_DIR>"
  exit 1
fi

RAW_SHORT="$DATA_DIR/short_reads"
RAW_LONG="$DATA_DIR/long_reads"

# ===============================
# Sanity checks
# ===============================
[[ -d "$RAW_SHORT" ]] || { echo "❌ Missing short_reads: $RAW_SHORT"; exit 1; }
[[ -d "$RAW_LONG"  ]] || { echo "❌ Missing long_reads:  $RAW_LONG";  exit 1; }

echo "📂 Validating raw reads (READ-ONLY):"
echo "  - $RAW_SHORT"
echo "  - $RAW_LONG"

# ===============================
# Validate SHORT reads
# ===============================
R1_FILES=("$RAW_SHORT"/*_1.fastq.gz)
R2_FILES=("$RAW_SHORT"/*_2.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 || ${#R2_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE paired-end Illumina sample"
  exit 1
fi

R1="$(basename "${R1_FILES[0]}")"
R2="$(basename "${R2_FILES[0]}")"

SAMPLE_NAME="${R1%%_1.fastq.gz}"

# ===============================
# Validate LONG reads
# ===============================
LONG_FILES=("$RAW_LONG"/*.fastq.gz)

if [[ ${#LONG_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE long-read FASTQ file"
  exit 1
fi

LONG_READ="$(basename "${LONG_FILES[0]}")"

# ===============================
# Final confirmation
# ===============================
echo "✅ Raw reads validated (READ-ONLY)"
echo "🧬 Detected sample: $SAMPLE_NAME"
echo "Short reads:"
echo "  - $RAW_SHORT/$R1"
echo "  - $RAW_SHORT/$R2"
echo "Long reads:"
echo "  - $RAW_LONG/$LONG_READ"
