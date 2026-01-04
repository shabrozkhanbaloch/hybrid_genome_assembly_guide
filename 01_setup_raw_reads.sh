#!/bin/bash
set -euo pipefail
shopt -s nullglob

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
RAW=$1

if [ -z "$RAW" ]; then
  echo "Usage: 01_setup_raw_reads.sh <RAW_DIR>"
  exit 1
fi

RAW_SHORT="$RAW/short_reads"
RAW_LONG="$RAW/long_reads"

mkdir -p "$RAW_SHORT" "$RAW_LONG"

# ===============================
# Validate SHORT reads
# ===============================
cd "$RAW_SHORT"

R1_FILES=(*_1.fastq.gz)
R2_FILES=(*_2.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 || ${#R2_FILES[@]} -ne 1 ]]; then
  echo "ERROR: Expected exactly ONE paired-end Illumina sample in $RAW_SHORT"
  exit 1
fi

R1="${R1_FILES[0]}"
R2="${R2_FILES[0]}"

SAMPLE_NAME=$(basename "$R1" | sed 's/_1.fastq.gz//')

[[ "$R1" == "${SAMPLE_NAME}_1.fastq.gz" ]] || mv "$R1" "${SAMPLE_NAME}_1.fastq.gz"
[[ "$R2" == "${SAMPLE_NAME}_2.fastq.gz" ]] || mv "$R2" "${SAMPLE_NAME}_2.fastq.gz"

# ===============================
# Validate LONG reads
# ===============================
cd "$RAW_LONG"

LONG_FILES=(*.fastq.gz)

if [[ ${#LONG_FILES[@]} -ne 1 ]]; then
  echo "ERROR: Expected exactly ONE long-read FASTQ file in $RAW_LONG"
  exit 1
fi

LONG_READ="${LONG_FILES[0]}"

[[ "$LONG_READ" == "${SAMPLE_NAME}_long.fastq.gz" ]] || \
  mv "$LONG_READ" "${SAMPLE_NAME}_long.fastq.gz"

# ===============================
# Final confirmation
# ===============================
echo "Setup complete."
echo "Detected sample: ${SAMPLE_NAME}"
echo "Short reads:"
echo "  - ${RAW_SHORT}/${SAMPLE_NAME}_1.fastq.gz"
echo "  - ${RAW_SHORT}/${SAMPLE_NAME}_2.fastq.gz"
echo "Long reads:"
echo "  - ${RAW_LONG}/${SAMPLE_NAME}_long.fastq.gz"
