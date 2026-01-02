#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# -----------------------------
# Paths
# -----------------------------
BASE = Path("09_abricate")
OUTDIR = Path("11_plots/figures")
OUTDIR.mkdir(parents=True, exist_ok=True)

asm_file = BASE / "assembly_level/abricate_assembly_summary.tsv"
pls_file = BASE / "plasmid_level/abricate_plasmid_summary.tsv"

# -----------------------------
# Load data
# -----------------------------
df_asm = pd.read_csv(asm_file, sep="\t", comment="#")
df_pls = pd.read_csv(pls_file, sep="\t", comment="#")

# -----------------------------
# Infer database names from filenames
# -----------------------------
def extract_db_names(summary_path):
    df = pd.read_csv(summary_path, sep="\t")
    return {
        Path(row["#FILE"]).stem.replace("abricate_", "").replace("_assembly", "").replace("_plasmid", ""):
        row["NUM_FOUND"]
        for _, row in df.iterrows()
    }

asm_counts = extract_db_names(asm_file)
pls_counts = extract_db_names(pls_file)

# Convert to series (same order)
databases = sorted(set(asm_counts) | set(pls_counts))
asm_values = [asm_counts.get(db, 0) for db in databases]
pls_values = [pls_counts.get(db, 0) for db in databases]

# -----------------------------
# Color-blind safe palette
# -----------------------------
colors = {
    "Assembly": "#0072B2",   # blue
    "Plasmid":  "#D55E00"    # vermillion
}

# -----------------------------
# Plot
# -----------------------------
fig, axes = plt.subplots(1, 2, figsize=(12, 5), sharey=True)

# Assembly
bars1 = axes[0].bar(databases, asm_values, color=colors["Assembly"])
axes[0].set_title("Assembly-level AMR genes")
axes[0].set_ylabel("Number of AMR genes")
axes[0].set_xlabel("Database")

# Numbers on bars
for bar in bars1:
    h = bar.get_height()
    axes[0].text(bar.get_x() + bar.get_width()/2, h + 0.3, int(h),
                 ha="center", fontsize=10)

# Plasmid
bars2 = axes[1].bar(databases, pls_values, color=colors["Plasmid"])
axes[1].set_title("Plasmid-level AMR genes")
axes[1].set_xlabel("Database")

for bar in bars2:
    h = bar.get_height()
    axes[1].text(bar.get_x() + bar.get_width()/2, h + 0.3, int(h),
                 ha="center", fontsize=10)

# -----------------------------
# Legend (TOP CENTER – OUTSIDE)
# -----------------------------
fig.legend(
    handles=[
        plt.Rectangle((0, 0), 1, 1, color=colors["Assembly"]),
        plt.Rectangle((0, 0), 1, 1, color=colors["Plasmid"]),
    ],
    labels=["Assembly-level", "Plasmid-level"],
    loc="upper center",
    ncol=2,
    frameon=True,
    bbox_to_anchor=(0.5, 1.02)
)

# -----------------------------
# Figure title (higher)
# -----------------------------
fig.suptitle(
    "Figure 6. Antimicrobial Resistance Gene Comparison",
    fontsize=13,
    y=1.12
)

# -----------------------------
# Layout + save
# -----------------------------
plt.tight_layout(rect=[0, 0, 1, 0.95])

plt.savefig(
    OUTDIR / "Figure6_AMR_Gene_Comparison.png",
    dpi=300,
    bbox_inches="tight"
)

plt.close()
