#!/usr/bin/env python3

from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
from collections import Counter

# ======================================================
# Paths
# ======================================================
PROJECT = Path("/data/wgs_assembly/PROJECTS/paper_02")
AMR = PROJECT / "results/amr/plasmid_level"
OUT = PROJECT / "figures"
OUT.mkdir(exist_ok=True)

DBS = ["card", "ncbi", "resfinder", "vfdb"]

KEY_GENES = [
    "blaNDM-5",
    "blaOXA-181",
    "blaCTX-M-15",
    "rmtF",
    "sul1",
    "sul2",
    "aac(6')-Ib",
]

# ======================================================
# Panel A: genes per database
# ======================================================
db_counts = {}

for db in DBS:
    f = AMR / f"abricate_{db}_plasmid.tsv"
    df = pd.read_csv(f, sep="\t", comment="#", header=0)

    gene_col = df.columns[5]   # 🔑 FIX
    db_counts[db] = df[gene_col].nunique()

# ======================================================
# Panel B: key AMR genes
# ======================================================
gene_counter = Counter()

for db in DBS:
    f = AMR / f"abricate_{db}_plasmid.tsv"
    df = pd.read_csv(f, sep="\t", comment="#", header=0)

    gene_col = df.columns[5]   # 🔑 FIX

    for g in df[gene_col]:
        if g in KEY_GENES:
            gene_counter[g] += 1

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")
fig, axes = plt.subplots(1, 2, figsize=(11, 4))

# --- Panel A ---
ax = axes[0]
bars = ax.bar(DBS, [db_counts[d] for d in DBS],
              color="#D55E00", edgecolor="black")
ax.set_title("A. Plasmid AMR genes by database")
ax.set_ylabel("Number of genes")

for b in bars:
    ax.text(b.get_x()+b.get_width()/2, b.get_height()+0.8,
            str(int(b.get_height())), ha="center", fontsize=9)

# --- Panel B ---
ax = axes[1]
genes = list(gene_counter.keys())
counts = list(gene_counter.values())

bars = ax.bar(genes, counts, color="#0072B2", edgecolor="black")
ax.set_title("B. Clinically relevant plasmid AMR genes")
ax.set_xticklabels(genes, rotation=45, ha="right")

for b in bars:
    ax.text(b.get_x()+b.get_width()/2, b.get_height()+0.5,
            str(int(b.get_height())), ha="center", fontsize=9)

# ======================================================
# Save
# ======================================================
fig.suptitle(
    "Figure 6. Plasmid-associated antimicrobial resistance genes",
    fontsize=13, y=1.05
)

plt.tight_layout()
plt.savefig(OUT / "Figure6_Plasmid_AMR_Subplots.png",
            dpi=300, bbox_inches="tight")
plt.close()

print("✅ Figure 6 generated successfully")
