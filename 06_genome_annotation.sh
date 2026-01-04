#!/bin/bash
set -euo pipefail

eval "$(conda shell.bash hook)"
conda activate 05_genome_annotation

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=$1

if [ -z "$RESULTS" ]; then
  echo "Usage: 06_genome_annotation.sh <RESULTS_DIR>"
  exit 1
fi

ASM="$RESULTS/assembly"
ANN="$RESULTS/annotation"
BAKTA_DB="/data/databases_important/bakta_db/db-light"

mkdir -p \
  "$ANN/prokka/short_only" \
  "$ANN/prokka/long_only" \
  "$ANN/prokka/hybrid" \
  "$ANN/bakta/short_only" \
  "$ANN/bakta/long_only" \
  "$ANN/bakta/hybrid"

############################
# PROKKA
############################

prokka \
  --outdir "$ANN/prokka/short_only" \
  --prefix short_prokka \
  --kingdom Bacteria \
  --addgenes \
  --cpus 14 \
  "$ASM/01_short_only/assembly.fasta" \
  --force

prokka \
  --outdir "$ANN/prokka/long_only" \
  --prefix long_prokka \
  --kingdom Bacteria \
  --addgenes \
  --cpus 14 \
  "$ASM/02_long_only/assembly.fasta" \
  --force

prokka \
  --outdir "$ANN/prokka/hybrid" \
  --prefix hybrid_prokka \
  --kingdom Bacteria \
  --addgenes \
  --cpus 14 \
  "$ASM/03_hybrid/assembly.fasta" \
  --force

############################
# BAKTA
############################

bakta \
  "$ASM/01_short_only/assembly.fasta" \
  --db "$BAKTA_DB" \
  --threads 14 \
  --verbose \
  --output "$ANN/bakta/short_only" \
  --prefix short_bakta \
  --complete \
  --force

bakta \
  "$ASM/02_long_only/assembly.fasta" \
  --db "$BAKTA_DB" \
  --threads 14 \
  --verbose \
  --output "$ANN/bakta/long_only" \
  --prefix long_bakta \
  --complete \
  --force

bakta \
  "$ASM/03_hybrid/assembly.fasta" \
  --db "$BAKTA_DB" \
  --threads 14 \
  --verbose \
  --output "$ANN/bakta/hybrid" \
  --prefix hybrid_bakta \
  --complete \
  --force

echo "Genome annotation complete (Prokka + Bakta: short, long, hybrid)."
echo "Results saved in: $ANN"
