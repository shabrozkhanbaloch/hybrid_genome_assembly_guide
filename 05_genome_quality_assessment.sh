#!/bin/bash
set -euo pipefail

########################################
# Genome Quality Assessment
# CheckM2 + QUAST + BUSCO
########################################

eval "$(conda shell.bash hook)"

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=$1

if [ -z "$RESULTS" ]; then
  echo "Usage: 05_genome_quality_assessment.sh <RESULTS_DIR>"
  exit 1
fi

ASM="$RESULTS/assembly"
QA="$RESULTS/quality"

SHORT_ASM="$ASM/01_short_only/assembly.fasta"
LONG_ASM="$ASM/02_long_only/assembly.fasta"
HYBRID_ASM="$ASM/03_hybrid/assembly.fasta"

# EXACT SAME CheckM2 DB
CHECKM2_DMND="/data/databases_important/checkm2_db/CheckM2_database/uniref100.KO.1.dmnd"

# ===============================
# Sanity checks
# ===============================
for asm in "$SHORT_ASM" "$LONG_ASM" "$HYBRID_ASM"; do
  [[ -f "$asm" ]] || { echo "ERROR: Assembly not found: $asm"; exit 1; }
done

[[ -f "$CHECKM2_DMND" ]] || {
  echo "ERROR: CheckM2 DB not found: $CHECKM2_DMND"
  exit 1
}

# ===============================
# Prepare output directories
# ===============================
rm -rf "$QA/checkm2"
mkdir -p \
  "$QA/checkm2/short_only" \
  "$QA/checkm2/long_only" \
  "$QA/checkm2/hybrid" \
  "$QA/quast/short_only" \
  "$QA/quast/long_only" \
  "$QA/quast/hybrid" \
  "$QA/busco"

# ===============================
# CheckM2
# ===============================
conda activate 04a_checkm2
export CHECKM2DB="$CHECKM2_DMND"

checkm2 predict --threads 14 --allmodels --force \
  --input "$SHORT_ASM" \
  --output-directory "$QA/checkm2/short_only"

checkm2 predict --threads 14 --allmodels --force \
  --input "$LONG_ASM" \
  --output-directory "$QA/checkm2/long_only"

checkm2 predict --threads 14 --allmodels --force \
  --input "$HYBRID_ASM" \
  --output-directory "$QA/checkm2/hybrid"

# ===============================
# QUAST
# ===============================
conda activate 04b_quast

for type in 01_short_only 02_long_only 03_hybrid; do
  quast "$ASM/$type/assembly.fasta" \
    -o "$QA/quast/$type" \
    -t 14 \
    --circos --glimmer --rna-finding \
    --conserved-genes-finding \
    --use-all-alignments
done

# ===============================
# BUSCO
# ===============================
conda activate 04c_busco

busco -i "$SHORT_ASM" -l bacteria_odb10 -m genome -c 14 \
  --out_path "$QA/busco" -o short_only --force

busco -i "$LONG_ASM" -l bacteria_odb10 -m genome -c 14 \
  --out_path "$QA/busco" -o long_only --force

busco -i "$HYBRID_ASM" -l bacteria_odb10 -m genome -c 14 \
  --out_path "$QA/busco" -o hybrid --force

# ===============================
# Final message
# ===============================
echo "Genome quality assessment completed."
echo "Results in: $QA"
