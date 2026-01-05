#!/bin/bash
set -euo pipefail
shopt -s nullglob

PROJECT_DIR=${1:-}

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Usage: preflight_check.sh <PROJECT_DIR>"
  exit 1
fi

echo "=========================================="
echo " Preflight check (READ-ONLY)"
echo " Project: $PROJECT_DIR"
echo "=========================================="

DATA="$PROJECT_DIR/data"
RESULTS="$PROJECT_DIR/results"

RAW_SHORT="$DATA/short_reads"
RAW_LONG="$DATA/long_reads"

echo "[1/6] Checking project structure..."

[[ -d "$PROJECT_DIR" ]] || { echo "❌ Project dir missing"; exit 1; }
[[ -d "$DATA" ]]        || { echo "❌ data/ missing"; exit 1; }
[[ -d "$RESULTS" ]]     || { echo "❌ results/ missing (run 00_make_directories.sh)"; exit 1; }

echo "✅ Project directories OK"

echo
echo "[2/6] Checking raw data symlinks..."

if [[ ! -L "$RAW_SHORT" ]]; then
  echo "❌ short_reads is not a symlink"
  exit 1
fi

if [[ ! -L "$RAW_LONG" ]]; then
  echo "❌ long_reads is not a symlink"
  exit 1
fi

echo "✅ Raw data symlinks OK"

echo
echo "[3/6] Checking short reads..."

R1=("$RAW_SHORT"/*_1.fastq.gz)
R2=("$RAW_SHORT"/*_2.fastq.gz)

if [[ ${#R1[@]} -ne 1 || ${#R2[@]} -ne 1 ]]; then
  echo "❌ Expected exactly ONE paired-end Illumina sample"
  exit 1
fi

SAMPLE="${R1[0]##*/}"
SAMPLE="${SAMPLE%%_1.fastq.gz}"

echo "✅ Short reads OK (sample: $SAMPLE)"

echo
echo "[4/6] Checking long reads..."

LONG=("$RAW_LONG"/*.fastq.gz)

if [[ ${#LONG[@]} -ne 1 ]]; then
  echo "❌ Expected exactly ONE long-read FASTQ file"
  exit 1
fi

echo "✅ Long reads OK"

echo
echo "[5/6] Checking read accessibility..."

gzip -t "${R1[0]}" || { echo "❌ Corrupt R1 FASTQ"; exit 1; }
gzip -t "${R2[0]}" || { echo "❌ Corrupt R2 FASTQ"; exit 1; }
gzip -t "${LONG[0]}" || { echo "❌ Corrupt long-read FASTQ"; exit 1; }

echo "✅ FASTQ integrity OK"

echo
echo "[6/6] Final summary"
echo "------------------------------------------"
echo " Sample detected : $SAMPLE"
echo " Short reads     : ${R1[0]}, ${R2[0]}"
echo " Long reads      : ${LONG[0]}"
echo "------------------------------------------"

echo "✅ PRE-FLIGHT CHECK PASSED"
echo "🚀 Safe to run pipeline"
