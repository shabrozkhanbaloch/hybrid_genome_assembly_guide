#!/bin/bash
set -euo pipefail

########################################
# Genome Quality Assessment
# CheckM2 + QUAST + BUSCO
# (short-only, long-only, hybrid)
########################################

# Initialise conda
eval "$(conda shell.bash hook)"

# ===============================
# Paths
# ===============================

BASE="/data/wgs_assembly/hybrid_genome_assembly_guide"
ASM="$BASE/05_genome_assembly"
QA="$BASE/06_genome_quality_assessment"

SHORT_ASM="$ASM/01_short_only/assembly.fasta"
LONG_ASM="$ASM/02_long_only/assembly.fasta"
HYBRID_ASM="$ASM/03_hybrid/assembly.fasta"

# EXACT SAME CheckM2 DB you used in short-read pipeline
CHECKM2_DMND="/data/databases_important/checkm2_db/CheckM2_database/uniref100.KO.1.dmnd"

# ===============================
# Sanity checks
# ===============================

for asm in "$SHORT_ASM" "$LONG_ASM" "$HYBRID_ASM"; do
  if [[ ! -f "$asm" ]]; then
    echo "ERROR: Assembly not found: $asm"
    exit 1
  fi
done

if [[ ! -f "$CHECKM2_DMND" ]]; then
  echo "ERROR: CheckM2 DIAMOND database not found:"
  echo "  $CHECKM2_DMND"
  exit 1
fi

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
  "$QA/busco/short_only" \
  "$QA/busco/long_only" \
  "$QA/busco/hybrid"

# ===============================
# CheckM2
# ===============================

conda activate 04a_checkm2
export CHECKM2DB="$CHECKM2_DMND"

checkm2 predict \
  --threads 14 \
  --allmodels \
  --force \
  --input "$SHORT_ASM" \
  --output-directory "$QA/checkm2/short_only"

checkm2 predict \
  --threads 14 \
  --allmodels \
  --force \
  --input "$LONG_ASM" \
  --output-directory "$QA/checkm2/long_only"

checkm2 predict \
  --threads 14 \
  --allmodels \
  --force \
  --input "$HYBRID_ASM" \
  --output-directory "$QA/checkm2/hybrid"

# ===============================
# QUAST
# ===============================

conda activate 04b_quast

quast "$SHORT_ASM" \
  -o "$QA/quast/short_only" \
  -t 14 \
  --circos --glimmer --rna-finding \
  --conserved-genes-finding \
  --use-all-alignments

quast "$LONG_ASM" \
  -o "$QA/quast/long_only" \
  -t 14 \
  --circos --glimmer --rna-finding \
  --conserved-genes-finding \
  --use-all-alignments

quast "$HYBRID_ASM" \
  -o "$QA/quast/hybrid" \
  -t 14 \
  --circos --glimmer --rna-finding \
  --conserved-genes-finding \
  --use-all-alignments

# ===============================
# BUSCO
# ===============================
############################
# BUSCO (FIXED OUTPUT PATH)
############################
conda activate 04c_busco

busco \
  -i "$SHORT_ASM" \
  -l bacteria_odb10 \
  -m genome \
  -c 14 \
  --out_path "$QA/busco" \
  -o short_only \
  --force

busco \
  -i "$LONG_ASM" \
  -l bacteria_odb10 \
  -m genome \
  -c 14 \
  --out_path "$QA/busco" \
  -o long_only \
  --force

busco \
  -i "$HYBRID_ASM" \
  -l bacteria_odb10 \
  -m genome \
  -c 14 \
  --out_path "$QA/busco" \
  -o hybrid \
  --force


# ===============================
# Final message
# ===============================

echo "Genome quality assessment completed successfully."
echo "Results directory:"
echo "  $QA"
echo "  ├── checkm2"
echo "  ├── quast"
echo "  └── busco"
echo "CheckM2, QUAST, and BUSCO results are organized by assembly type (short-only, long-only, hybrid)."