#!/usr/bin/env python3

import matplotlib.pyplot as plt
import pandas as pd
from Bio import SeqIO
from pathlib import Path
import numpy as np

# ======================================================
# Paths
# ======================================================
BASE = Path("05_genome_assembly")
OUTDIR = Path("11_plots/figures")
OUTDIR.mkdir(parents=True, exist_ok=True)

assemblies = {
    "Short-read": BASE / "01_short_only/assembly.fasta",
    "Long-read":  BASE / "02_long_only/assembly.fasta",
    "Hybrid":     BASE / "03_hybrid/assembly.fasta",
}

# Okabe–Ito color-blind friendly palette
COLORS = {
    "Short-read": "#E69F00",  # orange
    "Long-read":  "#0072B2",  # blue
    "Hybrid":     "#009E73",  # green
}

# ======================================================
# GC calculation
# ======================================================
def gc_content(seq: str) -> float:
    seq = seq.upper()
    gc = seq.count("G") + seq.count("C")
    return (gc / len(seq)) * 100 if len(seq) > 0 else 0


data = []

for label, fasta in assemblies.items():
    for record in SeqIO.parse(fasta, "fasta"):
        data.append({
            "Assembly": label,
            "GC": gc_content(str(record.seq))
        })

df = pd.DataFrame(data)

# ======================================================
# Plot
# ======================================================
fig, ax = plt.subplots(figsize=(9, 5))

groups = df.groupby("Assembly")["GC"]
positions = np.arange(len(groups)) + 1

# Violin plots
violins = ax.violinplot(
    [groups.get_group(g) for g in groups.groups],
    positions=positions,
    widths=0.8,
    showmeans=False,
    showmedians=False,
    showextrema=False
)

for body, label in zip(violins["bodies"], groups.groups):
    body.set_facecolor(COLORS[label])
    body.set_edgecolor("black")
    body.set_alpha(0.9)

# Boxplots inside violins
ax.boxplot(
    [groups.get_group(g) for g in groups.groups],
    positions=positions,
    widths=0.18,
    patch_artist=True,
    boxprops=dict(facecolor="white", edgecolor="black"),
    medianprops=dict(color="black"),
    whiskerprops=dict(color="black"),
    capprops=dict(color="black")
)

# Mean points + labels
for i, label in enumerate(groups.groups, start=1):
    mean_gc = groups.get_group(label).mean()
    ax.scatter(i, mean_gc, color="black", s=60, zorder=4)
    ax.text(
        i, mean_gc + 0.4,
        f"{mean_gc:.2f}%",
        ha="center",
        fontsize=10,
        fontweight="bold"
    )

# ======================================================
# Formatting
# ======================================================
ax.set_xticks(positions)
ax.set_xticklabels(groups.groups, fontsize=11)

ax.set_ylabel("GC content (%)", fontsize=12)
ax.set_ylim(30, 46)  # tight biologically meaningful range

ax.set_title(
    "Figure 4. GC Content Distribution Across Assemblies\n"
    "Hybrid assembly shows reduced GC bias and tighter distribution",
    fontsize=13
)

ax.grid(axis="y", linestyle="--", alpha=0.4)

# Legend (outside plot)
handles = [
    plt.Line2D([0], [0], color=COLORS[k], lw=8)
    for k in COLORS
]
ax.legend(
    handles,
    COLORS.keys(),
    title="Assembly type",
    loc="upper left",
    bbox_to_anchor=(1.02, 1),
    frameon=True
)

plt.tight_layout()

# ======================================================
# Save
# ======================================================
plt.savefig(OUTDIR / "Figure4_GC_Content_Distribution.png", dpi=300)
plt.show()
