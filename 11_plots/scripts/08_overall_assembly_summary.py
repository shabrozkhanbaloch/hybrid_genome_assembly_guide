#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# -----------------------------
# Paths
# -----------------------------
BASE = Path("06_genome_quality_assessment")
OUT = Path("11_plots/figures")
OUT.mkdir(parents=True, exist_ok=True)

# CheckM2
CHECKM = {
    "Short": BASE / "checkm2/short_only/quality_report.tsv",
    "Long": BASE / "checkm2/long_only/quality_report.tsv",
    "Hybrid": BASE / "checkm2/hybrid/quality_report.tsv",
}

# QUAST
QUAST = {
    "Short": BASE / "quast/short_only/report.tsv",
    "Long": BASE / "quast/long_only/report.tsv",
    "Hybrid": BASE / "quast/hybrid/report.tsv",
}

# Abricate (assembly level)
ABRICATE = Path("09_abricate/assembly_level/abricate_assembly_summary.tsv")

# -----------------------------
# Load CheckM2
# -----------------------------
completeness = []
contamination = []

for asm, path in CHECKM.items():
    df = pd.read_csv(path, sep="\t")
    completeness.append(df.loc[0, "Completeness_General"])
    contamination.append(df.loc[0, "Contamination"])

# -----------------------------
# Load QUAST N50
# -----------------------------
n50 = []
for asm, path in QUAST.items():
    df = pd.read_csv(path, sep="\t")
    row = df[df["Assembly"] == "N50"]
    n50.append(float(row.iloc[0, 1]) / 1000)  # kb

# -----------------------------
# Load Abricate (AMR count)
# -----------------------------
df_amr = pd.read_csv(ABRICATE, sep="\t")
total_amr = df_amr["NUM_FOUND"].sum()
amr_total = [0, 0, total_amr]


labels = ["Short", "Long", "Hybrid"]
x = np.arange(len(labels))
colors = ["#0072B2", "#D55E00", "#009E73"]  # color-blind safe

# -----------------------------
# Plot
# -----------------------------
fig, axes = plt.subplots(2, 2, figsize=(10, 7))

# Completeness
axes[0, 0].bar(x, completeness, color=colors)
axes[0, 0].set_title("Completeness (%)")
axes[0, 0].set_ylim(0, 105)

# Contamination
axes[0, 1].bar(x, contamination, color=colors)
axes[0, 1].set_title("Contamination (%)")

# N50
axes[1, 0].bar(x, n50, color=colors)
axes[1, 0].set_title("N50 (kb)")

# AMR genes
axes[1, 1].bar(x, amr_total, color=colors)
axes[1, 1].set_title("AMR genes (assembly-level)")

# -----------------------------
# Formatting
# -----------------------------
for ax in axes.flat:
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    for bar in ax.patches:
        h = bar.get_height()
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            h + 0.02 * max(h, 1),
            f"{h:.1f}" if h < 100 else f"{int(h)}",
            ha="center",
            fontsize=9
        )

fig.suptitle(
    "Figure 8. Integrated Comparison of Short-read, Long-read and Hybrid Assemblies",
    fontsize=14
)

plt.tight_layout()
plt.savefig(OUT / "Figure8_Overall_Assembly_Summary.png", dpi=300)
plt.show()
