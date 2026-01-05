#!/usr/bin/env python3

import os
import argparse
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import numpy as np
from pathlib import Path

# ======================================================
# Argument parsing (CLI > ENV fallback)
# ======================================================
parser = argparse.ArgumentParser(
    description="Plot CheckM2 completeness vs contamination"
)

parser.add_argument(
    "--results",
    help="Path to RESULTS_DIR (overrides env RESULTS_DIR)",
)

parser.add_argument(
    "--figures",
    help="Path to FIGURES_DIR (overrides env FIGURES_DIR)",
)

args = parser.parse_args()

RESULTS_DIR = args.results or os.environ.get("RESULTS_DIR")
FIGURES_DIR = args.figures or os.environ.get("FIGURES_DIR")

if RESULTS_DIR is None or FIGURES_DIR is None:
    raise RuntimeError(
        "RESULTS_DIR and FIGURES_DIR must be provided either via "
        "command-line arguments or environment variables"
    )

RESULTS_DIR = Path(RESULTS_DIR)
FIGURES_DIR = Path(FIGURES_DIR)
FIGURES_DIR.mkdir(parents=True, exist_ok=True)

# ======================================================
# Input files
# ======================================================
BASE = RESULTS_DIR / "quality" / "checkm2"

assemblies = {
    "Short-read": BASE / "short_only" / "quality_report.tsv",
    "Long-read":  BASE / "long_only" / "quality_report.tsv",
    "Hybrid":     BASE / "hybrid" / "quality_report.tsv",
}

labels = []
completeness = []
contamination = []

# ======================================================
# Load data (robust)
# ======================================================
for name, path in assemblies.items():
    if not path.exists():
        raise FileNotFoundError(f"Missing CheckM2 file: {path}")

    df = pd.read_csv(path, sep="\t")

    required = {"Completeness_General", "Contamination"}
    if not required.issubset(df.columns):
        raise ValueError(f"Unexpected columns in {path}")

    labels.append(name)
    completeness.append(float(df["Completeness_General"].iloc[0]))
    contamination.append(float(df["Contamination"].iloc[0]))

x = np.arange(len(labels))

# ======================================================
# Plot styling (Okabe–Ito, color-blind safe)
# ======================================================
COLOR_COMPLETENESS = "#0072B2"
COLOR_CONTAM       = "#D55E00"

plt.style.use("seaborn-v0_8-whitegrid")
fig, ax1 = plt.subplots(figsize=(8, 5))

# ======================================================
# Bar plot – completeness
# ======================================================
bars = ax1.bar(
    x,
    completeness,
    width=0.6,
    color=COLOR_COMPLETENESS,
    edgecolor="black",
)

ax1.set_ylabel("Completeness (%)")
ax1.set_ylim(0, 105)
ax1.set_xticks(x)
ax1.set_xticklabels(labels)

for bar in bars:
    h = bar.get_height()
    ax1.text(
        bar.get_x() + bar.get_width() / 2,
        h + 1,
        f"{h:.1f}%",
        ha="center",
        va="bottom",
        fontsize=10,
    )

# ======================================================
# Line plot – contamination (secondary axis)
# ======================================================
ax2 = ax1.twinx()
ax2.plot(
    x,
    contamination,
    color=COLOR_CONTAM,
    marker="o",
    linewidth=2,
)

ax2.set_ylabel("Contamination (%)")
ax2.set_ylim(0, max(1, max(contamination) + 0.5))

for xi, yi in zip(x, contamination):
    ax2.text(
        xi,
        yi + 0.1,
        f"{yi:.2f}%",
        color=COLOR_CONTAM,
        ha="center",
        va="bottom",
        fontsize=9,
    )

# ======================================================
# Title & legend
# ======================================================

legend_elements = [
    bars[0],
    Line2D([0], [0], color=COLOR_CONTAM, marker='o', lw=2)
]

ax1.legend(
    legend_elements,
    ["Completeness (%)", "Contamination (%)"],
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True,
)


# ======================================================
# Save
# ======================================================

output_file = FIGURES_DIR / "Figure1_CheckM2_Completeness_Contamination.png"

plt.savefig(
    output_file,
    dpi=300,
    bbox_inches="tight"   # <-- THIS is the key fix
)

plt.close()


print("✅ CheckM2 comparison plot generated")
print(f"📁 Output: {output_file}")
