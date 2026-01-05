#!/usr/bin/env python3

import argparse
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import sys

# ======================================================
# ARGUMENT PARSING (CLI > ENV)
# ======================================================
parser = argparse.ArgumentParser(
    description="Coverage depth distribution comparison"
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
    sys.exit(
        "❌ RESULTS_DIR and FIGURES_DIR must be provided via CLI or environment"
    )

RESULTS = Path(RESULTS_DIR)
OUTDIR  = Path(FIGURES_DIR)
OUTDIR.mkdir(parents=True, exist_ok=True)

COVERAGE = RESULTS / "quality" / "coverage"

# ======================================================
# Coverage folders (CONFIRMED STRUCTURE)
# ======================================================
folders = {
    "Short → Short":  COVERAGE / "short_reads" / "short_vs_short",
    "Short → Hybrid": COVERAGE / "short_reads" / "short_vs_hybrid",
    "Long → Hybrid":  COVERAGE / "long_reads" / "long_vs_hybrid",
}

# Okabe–Ito color-blind friendly palette
COLORS = {
    "Short → Short":  "#E69F00",
    "Short → Hybrid": "#0072B2",
    "Long → Hybrid":  "#009E73",
}

depth_data = {}

# ======================================================
# Load depth files
# ======================================================
for label, folder in folders.items():
    if not folder.exists():
        sys.exit(f"❌ Missing folder: {folder}")

    files = list(folder.glob("*depth*.txt")) + list(folder.glob("*depth*.tsv"))
    if not files:
        sys.exit(f"❌ No depth file found in {folder}")

    df = pd.read_csv(
        files[0],
        sep="\t",
        header=None,
        names=["contig", "pos", "depth"]
    )

    depth_data[label] = df["depth"]

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")
fig, ax = plt.subplots(figsize=(9, 5))

for label, depths in depth_data.items():
    depths = depths[depths > 0]

    ax.hist(
        depths,
        bins=200,
        density=True,
        alpha=0.45,
        color=COLORS[label],
        label=f"{label} (mean={depths.mean():.1f}×)"
    )

    ax.axvline(
        depths.mean(),
        color=COLORS[label],
        linestyle="--",
        linewidth=2
    )

# ======================================================
# Formatting
# ======================================================
ax.set_xscale("log")
ax.set_xlabel("Coverage depth (log scale)", fontsize=12)
ax.set_ylabel("Density", fontsize=12)

ax.set_title(
    "Coverage Depth Distribution Across Assemblies\n"
    "Hybrid assembly shows more uniform and stable coverage",
    fontsize=13
)

ax.legend(
    title="Mapping strategy",
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True
)

ax.grid(axis="y", linestyle="--", alpha=0.4)
plt.tight_layout()

# ======================================================
# Save
# ======================================================
outfile = OUTDIR / "Figure5_Coverage_Depth_Distribution.png"
plt.savefig(outfile, dpi=300)
plt.close()

print("✅ Coverage depth comparison plot generated")
print(f"📁 Output: {outfile}")
