#!/usr/bin/env python3

import argparse
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
from collections import Counter
import os
import sys

# ======================================================
# ARGUMENTS (CLI > ENV)
# ======================================================
parser = argparse.ArgumentParser(
    description="AMR gene comparison from Abricate results"
)

parser.add_argument("--results", help="RESULTS directory")
parser.add_argument("--figures", help="FIGURES directory")

args = parser.parse_args()

RESULTS_DIR = args.results or os.environ.get("RESULTS_DIR")
FIGURES_DIR = args.figures or os.environ.get("FIGURES_DIR")

if not RESULTS_DIR or not FIGURES_DIR:
    sys.exit("❌ RESULTS_DIR and FIGURES_DIR must be provided via CLI or ENV")

RESULTS = Path(RESULTS_DIR)
OUT = Path(FIGURES_DIR)
OUT.mkdir(parents=True, exist_ok=True)

# ======================================================
# Prefer plasmid_level, fallback to assembly_level
# ======================================================
AMR_BASE = RESULTS / "amr"

if (AMR_BASE / "plasmid_level").exists():
    AMR = AMR_BASE / "plasmid_level"
    LEVEL = "Plasmid-level"
elif (AMR_BASE / "assembly_level").exists():
    AMR = AMR_BASE / "assembly_level"
    LEVEL = "Assembly-level"
else:
    sys.exit("❌ No AMR results found")

# ======================================================
# Valid Abricate databases ONLY
# ======================================================
VALID_DBS = {"card", "ncbi", "resfinder", "vfdb", "plasmidfinder"}

DB_FILES = []
for f in AMR.glob("abricate_*.tsv"):
    parts = f.stem.split("_")
    if len(parts) >= 3 and parts[1] in VALID_DBS:
        DB_FILES.append(f)

if not DB_FILES:
    sys.exit("❌ No valid Abricate database files found")

# ======================================================
# Clinically relevant AMR gene FAMILIES
# ======================================================
KEY_GENES = [
    "blaNDM",
    "blaOXA",
    "blaCTX-M",
    "rmtF",
    "sul1",
    "sul2",
    "aac(6')-Ib",
]

# ======================================================
# Parse Abricate files
# ======================================================
db_counts = {}
gene_counter = Counter()

for f in DB_FILES:
    db = f.stem.split("_")[1]   # SAFE: validated above

    df = pd.read_csv(f, sep="\t", comment="#")

    if df.empty:
        continue

    gene_col = df.columns[5]   # Abricate GENE column

    db_counts[db] = df[gene_col].nunique()

    for g in df[gene_col]:
        for key in KEY_GENES:
            if key in g:
                gene_counter[key] += 1

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")
fig, axes = plt.subplots(1, 2, figsize=(11, 4))

# ---------------- Panel A ----------------
ax = axes[0]
bars = ax.bar(
    db_counts.keys(),
    db_counts.values(),
    color="#D55E00",
    edgecolor="black"
)
ax.set_title("A. AMR genes by database")
ax.set_ylabel("Number of unique AMR genes")

for b in bars:
    ax.text(
        b.get_x() + b.get_width() / 2,
        b.get_height() + 0.5,
        str(int(b.get_height())),
        ha="center",
        fontsize=9
    )

# ---------------- Panel B ----------------
ax = axes[1]
genes = list(gene_counter.keys())
counts = list(gene_counter.values())

bars = ax.bar(
    genes,
    counts,
    color="#0072B2",
    edgecolor="black"
)
ax.set_title("B. Clinically relevant AMR gene families")
ax.set_ylabel("Number of plasmid contigs")
ax.set_xticklabels(genes, rotation=45, ha="right")

for b in bars:
    ax.text(
        b.get_x() + b.get_width() / 2,
        b.get_height() + 0.5,
        str(int(b.get_height())),
        ha="center",
        fontsize=9
    )

# ======================================================
# Final formatting
# ======================================================
fig.suptitle(
    f"Figure 6. Plasmid-associated antimicrobial resistance genes",
    fontsize=13,
    y=1.05
)

plt.tight_layout()
outfile = OUT / "Figure6_AMR_Gene_Comparison.png"
plt.savefig(outfile, dpi=300, bbox_inches="tight")
plt.close()

print("✅ AMR gene comparison plot generated")
print(f"📁 Output: {outfile}")
