#!/usr/bin/env python3

import argparse
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
import os
import sys

# ======================================================
# ARGUMENTS (CLI > ENV)
# ======================================================
parser = argparse.ArgumentParser(
    description="Integrated assembly quality comparison (CheckM2 + QUAST)"
)

parser.add_argument("--results", help="RESULTS directory")
parser.add_argument("--figures", help="FIGURES directory")

args = parser.parse_args()

RESULTS_DIR = args.results or os.environ.get("RESULTS_DIR")
FIGURES_DIR = args.figures or os.environ.get("FIGURES_DIR")

if not RESULTS_DIR or not FIGURES_DIR:
    sys.exit("❌ RESULTS_DIR and FIGURES_DIR must be provided via CLI or ENV")

RESULTS = Path(RESULTS_DIR)
OUTDIR  = Path(FIGURES_DIR)
OUTDIR.mkdir(parents=True, exist_ok=True)

# ======================================================
# Input paths
# ======================================================
CHECKM = {
    "Short-read": RESULTS / "quality/checkm2/short_only/quality_report.tsv",
    "Long-read":  RESULTS / "quality/checkm2/long_only/quality_report.tsv",
    "Hybrid":     RESULTS / "quality/checkm2/hybrid/quality_report.tsv",
}

QUAST = {
    "Short-read": RESULTS / "quality/quast/01_short_only/transposed_report.tsv",
    "Long-read":  RESULTS / "quality/quast/02_long_only/transposed_report.tsv",
    "Hybrid":     RESULTS / "quality/quast/03_hybrid/transposed_report.tsv",
}

# ======================================================
# Load CheckM2 metrics
# ======================================================
completeness = []
contamination = []

for asm, path in CHECKM.items():
    if not path.exists():
        sys.exit(f"❌ Missing CheckM2 file: {path}")

    df = pd.read_csv(path, sep="\t")
    completeness.append(float(df.loc[0, "Completeness_General"]))
    contamination.append(float(df.loc[0, "Contamination"]))

# ======================================================
# Load QUAST N50 (kb)
# ======================================================
n50 = []

for asm, path in QUAST.items():
    if not path.exists():
        sys.exit(f"❌ Missing QUAST file: {path}")

    df = pd.read_csv(path, sep="\t", index_col=0)

    n50_col = [c for c in df.columns if c.lower() == "n50"]
    if not n50_col:
        sys.exit(f"❌ N50 column not found in {path}")

    n50.append(float(df[n50_col[0]].iloc[0]) / 1000)  # kb

# ======================================================
# Plot setup
# ======================================================
labels = ["Short-read", "Long-read", "Hybrid"]
x = np.arange(len(labels))

colors = ["#0072B2", "#D55E00", "#009E73"]  # Okabe–Ito

plt.style.use("seaborn-v0_8-whitegrid")
fig, axes = plt.subplots(1, 3, figsize=(12, 4))

# ---------------- Panel 1 ----------------
axes[0].bar(x, completeness, color=colors, edgecolor="black")
axes[0].set_title("Completeness (%)")
axes[0].set_ylim(0, 105)

# ---------------- Panel 2 ----------------
axes[1].bar(x, contamination, color=colors, edgecolor="black")
axes[1].set_title("Contamination (%)")

# ---------------- Panel 3 ----------------
axes[2].bar(x, n50, color=colors, edgecolor="black")
axes[2].set_title("N50 (kb)")

# ======================================================
# Shared formatting + labels
# ======================================================
for ax in axes:
    ax.set_xticks(x)
    ax.set_xticklabels(labels)

    for bar in ax.patches:
        h = bar.get_height()
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            h + max(h * 0.03, 0.5),
            f"{h:.1f}",
            ha="center",
            fontsize=9
        )

# ======================================================
# Global title
# ======================================================
fig.suptitle(
    "Figure 8. Integrated comparison of short-read, long-read and hybrid assemblies",
    fontsize=13,
    y=1.05
)

plt.tight_layout()

# ======================================================
# Save
# ======================================================
outfile = OUTDIR / "Figure8_Overall_Assembly_Quality.png"
plt.savefig(outfile, dpi=300, bbox_inches="tight")
plt.close()

print("✅ Overall assembly quality summary plot generated")
print(f"📁 Output: {outfile}")
