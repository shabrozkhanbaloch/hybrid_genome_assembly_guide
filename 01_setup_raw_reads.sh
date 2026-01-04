#!/bin/bash
set -euo pipefail
shopt -s nullglob

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
  echo "Usage: 01_setup_raw_reads.sh <PROJECT_DIR>"
  echo "Example: 01_setup_raw_reads.sh /data/wgs_assembly/PROJECTS/paper_02"
  exit 1
fi

RAW="$PROJECT_DIR/raw_reads"

RAW_SHORT="$RAW/short_reads"
RAW_LONG="$RAW/long_reads"

# ===============================
# Sanity checks
# ===============================
[[ -d "$RAW" ]] || { echo "❌ RAW directory not found: $RAW"; exit 1; }

mkdir -p "$RAW_SHORT" "$RAW_LONG"

echo "📂 Setting up raw reads in:"
echo "  - $RAW_SHORT"
echo "  - $RAW_LONG"

# ===============================
# Validate SHORT reads
# ===============================
cd "$RAW_SHORT"

R1_FILES=(*_1.fastq.gz)
R2_FILES=(*_2.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 || ${#R2_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE paired-end Illumina sample in $RAW_SHORT"
  echo "Found:"
  echo "  R1: ${#R1_FILES[@]}"
  echo "  R2: ${#R2_FILES[@]}"
  exit 1
fi

R1="${R1_FILES[0]}"
R2="${R2_FILES[0]}"

SAMPLE_NAME=$(basename "$R1" | sed 's/_1.fastq.gz//')

mv -f "$R1" "${SAMPLE_NAME}_1.fastq.gz"
mv -f "$R2" "${SAMPLE_NAME}_2.fastq.gz"

# ===============================
# Validate LONG reads
# ===============================
cd "$RAW_LONG"

LONG_FILES=(*.fastq.gz)

if [[ ${#LONG_FILES[@]} -ne 1 ]]; then
  echo "❌ ERROR: Expected exactly ONE long-read FASTQ file in $RAW_LONG"
  exit 1
fi

LONG_READ="${LONG_FILES[0]}"

mv -f "$LONG_READ" "${SAMPLE_NAME}_long.fastq.gz"

# ===============================
# Final confirmation
# ===============================
echo "✅ Raw read setup complete"
echo "🧬 Detected sample: ${SAMPLE_NAME}"
echo "Short reads:"
echo "  - ${RAW_SHORT}/${SAMPLE_NAME}_1.fastq.gz"
echo "  - ${RAW_SHORT}/${SAMPLE_NAME}_2.fastq.gz"
echo "Long reads:"
echo "  - ${RAW_LONG}/${SAMPLE_NAME}_long.fastq.gz"
