#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
from Bio import SeqIO
from pathlib import Path
import numpy as np
import os
import sys

# ======================================================
# ENV CHECK
# ======================================================
if "RESULTS_DIR" not in os.environ or "FIGURES_DIR" not in os.environ:
    sys.exit("❌ RESULTS_DIR or FIGURES_DIR not set. Use run_plots.sh")

RESULTS = Path(os.environ["RESULTS_DIR"])
FIGDIR  = Path(os.environ["FIGURES_DIR"])
FIGDIR.mkdir(parents=True, exist_ok=True)

# ======================================================
# ASSEMBLY FASTA PATHS (RESULTS-BASED)
# ======================================================
assemblies = {
    "Short-read": RESULTS / "assembly/01_short_only/assembly.fasta",
    "Long-read":  RESULTS / "assembly/02_long_only/assembly.fasta",
    "Hybrid":     RESULTS / "assembly/03_hybrid/assembly.fasta",
}

# ======================================================
# CHECK FILES
# ======================================================
for name, path in assemblies.items():
    if not path.exists():
        sys.exit(f"❌ Missing assembly FASTA: {path}")

# ======================================================
# COLOR-BLIND FRIENDLY (OKABE–ITO)
# ======================================================
COLORS = {
    "Short-read": "#E69F00",  # orange
    "Long-read":  "#0072B2",  # blue
    "Hybrid":     "#009E73",  # green
}

# ======================================================
# GC CALCULATION
# ======================================================
def gc_content(seq: str) -> float:
    seq = seq.upper()
    if len(seq) == 0:
        return 0
    return (seq.count("G") + seq.count("C")) / len(seq) * 100

data = []

for label, fasta in assemblies.items():
    for record in SeqIO.parse(fasta, "fasta"):
        data.append({
            "Assembly": label,
            "GC": gc_content(str(record.seq))
        })

df = pd.DataFrame(data)

# ======================================================
# ORDER (IMPORTANT FOR STORY)
# ======================================================
order = ["Short-read", "Long-read", "Hybrid"]
groups = df.groupby("Assembly")["GC"]
data_ordered = [groups.get_group(k) for k in order]

positions = np.arange(len(order)) + 1

# ======================================================
# PLOT
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")
fig, ax = plt.subplots(figsize=(8, 5))

# ---- violin
violins = ax.violinplot(
    data_ordered,
    positions=positions,
    widths=0.75,
    showmeans=False,
    showmedians=False,
    showextrema=False
)

for body, label in zip(violins["bodies"], order):
    body.set_facecolor(COLORS[label])
    body.set_edgecolor("black")
    body.set_alpha(0.9)

# ---- boxplot inside
ax.boxplot(
    data_ordered,
    positions=positions,
    widths=0.18,
    patch_artist=True,
    boxprops=dict(facecolor="white", edgecolor="black"),
    medianprops=dict(color="black", linewidth=2),
    whiskerprops=dict(color="black"),
    capprops=dict(color="black")
)

# ---- mean points + labels
for i, label in enumerate(order, start=1):
    mean_gc = data_ordered[i-1].mean()
    ax.scatter(i, mean_gc, color="black", s=50, zorder=5)
    ax.text(
        i,
        mean_gc + 0.6,
        f"{mean_gc:.2f}%",
        ha="center",
        va="bottom",
        fontsize=10,
        fontweight="bold"
    )

# ======================================================
# FORMATTING (NATURE STYLE)
# ======================================================
ax.set_xticks(positions)
ax.set_xticklabels(order, fontsize=11)
ax.set_ylabel("GC content (%)", fontsize=12)
ax.set_ylim(30, 55)

ax.set_title(
    "Figure 4. GC Content Distribution Across Assemblies\n"
    "Hybrid assembly shows reduced GC bias and tighter distribution",
    fontsize=13
)

ax.grid(axis="y", linestyle="--", alpha=0.4)

plt.tight_layout()

# ======================================================
# SAVE
# ======================================================
outfile = FIGDIR / "Figure4_GC_Content_Distribution.png"
plt.savefig(outfile, dpi=300)
plt.close()

print("✅ GC content comparison plot generated")
print(f"📁 Output: {outfile}")
