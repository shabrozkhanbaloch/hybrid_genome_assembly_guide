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

# ===============================
# SANITY CHECKS
# ===============================
[[ -d "$ASM" ]] || { echo "❌ Assembly directory not found: $ASM"; exit 1; }
[[ -d "$BAKTA_DB" ]] || { echo "❌ Bakta DB not found: $BAKTA_DB"; exit 1; }

for type in 01_short_only 02_long_only 03_hybrid; do
  [[ -f "$ASM/$type/assembly.fasta" ]] || {
    echo "❌ Missing assembly: $ASM/$type/assembly.fasta"
    exit 1
  }
done

# ===============================
# OUTPUT DIRECTORIES
# ===============================
mkdir -p \
  "$ANN/prokka"/{01_short_only,02_long_only,03_hybrid} \
  "$ANN/bakta"/{01_short_only,02_long_only,03_hybrid}

# ===============================
# PROKKA
# ===============================
echo "🔬 Running Prokka annotations..."

for type in 01_short_only 02_long_only 03_hybrid; do
  echo "  → Prokka: $type"

  prokka \
    --outdir "$ANN/prokka/$type" \
    --prefix "$type" \
    --kingdom Bacteria \
    --addgenes \
    --cpus 14 \
    "$ASM/$type/assembly.fasta" \
    --force
done

# ===============================
# BAKTA
# ===============================
echo "🧬 Running Bakta annotations..."

for type in 01_short_only 02_long_only 03_hybrid; do
  echo "  → Bakta: $type"

  bakta \
    "$ASM/$type/assembly.fasta" \
    --db "$BAKTA_DB" \
    --threads 14 \
    --verbose \
    --output "$ANN/bakta/$type" \
    --prefix "$type" \
    --complete \
    --force
done

# ===============================
# DONE
# ===============================
echo "✅ Genome annotation completed successfully"
echo "📁 Results stored in: $ANN"
