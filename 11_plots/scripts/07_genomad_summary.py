#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# -----------------------------
# Paths
# -----------------------------
BASE = Path("10_genomad")

HYBRID_FILE = BASE / "assembly_level/assembly_aggregated_classification/assembly_aggregated_classification.tsv"
PLASMID_FILE = BASE / "plasmid_level/plassembler_plasmids_aggregated_classification/plassembler_plasmids_aggregated_classification.tsv"

OUT = Path("11_plots/figures")
OUT.mkdir(parents=True, exist_ok=True)

# -----------------------------
# Load data
# -----------------------------
def load_counts(path):
    if not path.exists():
        raise FileNotFoundError(f"Missing geNomad file: {path}")

    df = pd.read_csv(path, sep="\t")

    # geNomad gives scores, not labels → take max score as class
    class_map = {
        "virus_score": "Virus",
        "plasmid_score": "Plasmid",
        "chromosome_score": "Chromosome",
    }

    scores = df[list(class_map.keys())]
    labels = scores.idxmax(axis=1).map(class_map)

    return labels.value_counts().to_dict()

hybrid_counts = load_counts(HYBRID_FILE)
plasmid_counts = load_counts(PLASMID_FILE)

# -----------------------------
# Categories
# -----------------------------
hybrid_labels = ["Virus", "Plasmid", "Chromosome"]
hybrid_values = [hybrid_counts.get(k, 0) for k in hybrid_labels]

plasmid_labels = ["Virus", "Plasmid"]          # ✅ Chromosome removed
plasmid_values = [plasmid_counts.get(k, 0) for k in plasmid_labels]

# Color-blind friendly palette
colors = {
    "Virus": "#0072B2",
    "Plasmid": "#D55E00",
    "Chromosome": "#009E73",
}

# -----------------------------
# Plot
# -----------------------------
fig, axes = plt.subplots(1, 2, figsize=(10, 4), sharey=True)

# Hybrid assembly
bars1 = axes[0].bar(
    hybrid_labels,
    hybrid_values,
    color=[colors[k] for k in hybrid_labels]
)
axes[0].set_title("Hybrid Assembly")
axes[0].set_ylabel("Number of contigs")

# Plasmid assembly
bars2 = axes[1].bar(
    plasmid_labels,
    plasmid_values,
    color=[colors[k] for k in plasmid_labels]
)
axes[1].set_title("Plasmid Assembly")

# -----------------------------
# Numbers on bars
# -----------------------------
def label_bars(bars, ax):
    for b in bars:
        h = b.get_height()
        ax.text(
            b.get_x() + b.get_width() / 2,
            h + 0.05,
            f"{int(h)}",
            ha="center",
            va="bottom",
            fontsize=10
        )

label_bars(bars1, axes[0])
label_bars(bars2, axes[1])

# -----------------------------
# Legend (outside, top)
# -----------------------------
handles = [plt.Rectangle((0, 0), 1, 1, color=colors[k]) for k in colors]
labels = list(colors.keys())

fig.legend(
    handles,
    labels,
    loc="upper center",
    ncol=3,
    frameon=True
)

fig.suptitle(
    "Figure 7. geNomad-based Classification of Contigs in Hybrid and Plasmid Assemblies",
    y=1.08
)

plt.tight_layout()
plt.savefig(OUT / "Figure7_geNomad_Classification.png", dpi=300, bbox_inches="tight")
plt.show()
