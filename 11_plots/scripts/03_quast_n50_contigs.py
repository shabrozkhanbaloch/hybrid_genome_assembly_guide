#!/usr/bin/env python3

import os
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# ======================================================
# Argument parsing (CLI > ENV)
# ======================================================
parser = argparse.ArgumentParser(
    description="QUAST N50 & contig count comparison plot"
)

parser.add_argument(
    "--results",
    help="Path to RESULTS directory"
)

parser.add_argument(
    "--figures",
    help="Path to FIGURES directory"
)

args = parser.parse_args()

RESULTS_DIR = args.results or os.environ.get("RESULTS_DIR")
FIGURES_DIR = args.figures or os.environ.get("FIGURES_DIR")

if not RESULTS_DIR or not FIGURES_DIR:
    raise RuntimeError(
        "RESULTS_DIR and FIGURES_DIR must be provided via CLI or environment"
    )

# ======================================================
# Paths
# ======================================================
BASE = Path(RESULTS_DIR) / "quality" / "quast"
OUT  = Path(FIGURES_DIR)
OUT.mkdir(parents=True, exist_ok=True)

assemblies = {
    "Short-read": BASE / "01_short_only",
    "Long-read":  BASE / "02_long_only",
    "Hybrid":     BASE / "03_hybrid",
}

labels = []
n50 = []
contigs = []

# ======================================================
# Load QUAST data
# ======================================================
for label, folder in assemblies.items():

    transposed = folder / "transposed_report.tsv"
    normal     = folder / "report.tsv"

    if transposed.exists():
        df = pd.read_csv(transposed, sep="\t")
        df = df.set_index(df.columns[0])

        n50_val = df.iloc[0]["N50"]
        contig_val = df.iloc[0]["# contigs"]

    elif normal.exists():
        df = pd.read_csv(normal, sep="\t").set_index("Assembly")

        n50_val = df.loc["N50"].values[0]
        contig_val = df.loc["# contigs"].values[0]

    else:
        raise FileNotFoundError(f"No QUAST report found in {folder}")

    labels.append(label)
    n50.append(int(n50_val))
    contigs.append(int(contig_val))

x = np.arange(len(labels))

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")
fig, ax1 = plt.subplots(figsize=(8, 5))

COLOR_N50 = "#009E73"
COLOR_CONTIGS = "#CC79A7"

bars = ax1.bar(
    x,
    n50,
    width=0.6,
    color=COLOR_N50,
    edgecolor="black",
    label="N50 (bp)"
)

ax1.set_ylabel("N50 (bp)")
ax1.set_xticks(x)
ax1.set_xticklabels(labels)

for bar in bars:
    h = bar.get_height()
    ax1.text(
        bar.get_x() + bar.get_width() / 2,
        h + (0.02 * max(n50)),
        f"{h:,}",
        ha="center",
        va="bottom",
        fontsize=10
    )

ax2 = ax1.twinx()
line = ax2.plot(
    x,
    contigs,
    color=COLOR_CONTIGS,
    marker="o",
    linewidth=2,
    label="Number of contigs"
)

ax2.set_ylabel("Number of contigs")
ax2.set_ylim(0, max(contigs) + 5)

for xi, yi in zip(x, contigs):
    ax2.text(
        xi,
        yi + 0.5,
        str(yi),
        color=COLOR_CONTIGS,
        ha="center",
        va="bottom",
        fontsize=9
    )

ax1.set_title("Assembly continuity and fragmentation (QUAST)")

handles = [bars[0], line[0]]
labels_leg = ["N50 (bp)", "Number of contigs"]

ax1.legend(
    handles,
    labels_leg,
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True
)

plt.tight_layout()

outfile = OUT / "Figure3_QUAST_N50_Contigs.png"
plt.savefig(outfile, dpi=300)
plt.close()

print("✅ QUAST comparison plot generated successfully")
print(f"📁 Output: {outfile}")
