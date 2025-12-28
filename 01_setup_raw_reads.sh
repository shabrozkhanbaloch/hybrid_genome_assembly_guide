#!/bin/bash
set -euo pipefail
shopt -s nullglob

# Initialise conda for non-interactive shell
eval "$(conda shell.bash hook)"

# ===============================
# Set directories
# ===============================

# Input drop locations (can be external in future)
SOURCE_SHORT="/data/wgs_assembly/hybrid_genome_assembly_guide/01_raw_reads/short_reads"
SOURCE_LONG="/data/wgs_assembly/hybrid_genome_assembly_guide/01_raw_reads/long_reads"

# Working locations (same for now, but kept explicit)
WORK_DIR="/data/wgs_assembly/hybrid_genome_assembly_guide"
RAW_SHORT="${WORK_DIR}/01_raw_reads/short_reads"
RAW_LONG="${WORK_DIR}/01_raw_reads/long_reads"

mkdir -p "${RAW_SHORT}" "${RAW_LONG}"

# ===============================
# Copy FASTQs (NO overwrite)
# ===============================

for f in "${SOURCE_SHORT}"/*.fastq.gz; do
  base=$(basename "$f")
  [[ -f "${RAW_SHORT}/${base}" ]] || cp "$f" "${RAW_SHORT}/"
done

for f in "${SOURCE_LONG}"/*.fastq.gz; do
  base=$(basename "$f")
  [[ -f "${RAW_LONG}/${base}" ]] || cp "$f" "${RAW_LONG}/"
done

# ===============================
# Validate SHORT reads
# ===============================

cd "${RAW_SHORT}"

R1_FILES=(*_1.fastq.gz)
R2_FILES=(*_2.fastq.gz)

if [[ ${#R1_FILES[@]} -ne 1 || ${#R2_FILES[@]} -ne 1 ]]; then
  echo "ERROR: Expected exactly ONE paired-end Illumina sample in ${RAW_SHORT}"
  exit 1
fi

R1="${R1_FILES[0]}"
R2="${R2_FILES[0]}"

SAMPLE_NAME=$(basename "$R1" | sed 's/_1.fastq.gz//')

# Rename only if required
[[ "$R1" == "${SAMPLE_NAME}_1.fastq.gz" ]] || mv "$R1" "${SAMPLE_NAME}_1.fastq.gz"
[[ "$R2" == "${SAMPLE_NAME}_2.fastq.gz" ]] || mv "$R2" "${SAMPLE_NAME}_2.fastq.gz"

# ===============================
# Validate LONG reads
# ===============================

cd "${RAW_LONG}"

LONG_FILES=(*.fastq.gz)

if [[ ${#LONG_FILES[@]} -ne 1 ]]; then
  echo "ERROR: Expected exactly ONE long-read FASTQ file in ${RAW_LONG}"
  exit 1
fi

LONG_READ="${LONG_FILES[0]}"

# Standardise long-read name
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
