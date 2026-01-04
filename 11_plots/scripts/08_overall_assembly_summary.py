#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# ======================================================
# Resolve PROJECT directory robustly
# ======================================================
PROJECT_DIR = Path(__file__).resolve().parents[3] / "PROJECTS" / "paper_02"
RESULTS = PROJECT_DIR / "results"
OUTDIR = PROJECT_DIR / "figures"
OUTDIR.mkdir(parents=True, exist_ok=True)

# ======================================================
# Input paths
# ======================================================
CHECKM = {
    "Short": RESULTS / "quality/checkm2/short_only/quality_report.tsv",
    "Long": RESULTS / "quality/checkm2/long_only/quality_report.tsv",
    "Hybrid": RESULTS / "quality/checkm2/hybrid/quality_report.tsv",
}

QUAST = {
    "Short": RESULTS / "quality/quast/01_short_only/transposed_report.tsv",
    "Long": RESULTS / "quality/quast/02_long_only/transposed_report.tsv",
    "Hybrid": RESULTS / "quality/quast/03_hybrid/transposed_report.tsv",
}

# ======================================================
# Load CheckM2 metrics
# ======================================================
completeness = []
contamination = []

for asm, path in CHECKM.items():
    if not path.exists():
        raise FileNotFoundError(f"Missing CheckM2 file: {path}")

    df = pd.read_csv(path, sep="\t")
    completeness.append(float(df.loc[0, "Completeness_General"]))
    contamination.append(float(df.loc[0, "Contamination"]))

# ======================================================
# Load QUAST N50 (kb) – robust
# ======================================================
n50 = []

for asm, path in QUAST.items():
    if not path.exists():
        raise FileNotFoundError(f"Missing QUAST file: {path}")

    df = pd.read_csv(path, sep="\t", index_col=0)

    # Case-insensitive N50 detection
    n50_col = [c for c in df.columns if c.lower() == "n50"]
    if not n50_col:
        raise KeyError(f"N50 column not found in {path}")

    n50.append(float(df[n50_col[0]].iloc[0]) / 1000)  # kb

# ======================================================
# Plot setup
# ======================================================
labels = ["Short-read", "Long-read", "Hybrid"]
x = np.arange(len(labels))

colors = ["#0072B2", "#D55E00", "#009E73"]  # Okabe–Ito palette

plt.style.use("seaborn-v0_8-whitegrid")

fig, axes = plt.subplots(1, 3, figsize=(12, 4))

# ======================================================
# Panel 1: Completeness
# ======================================================
axes[0].bar(x, completeness, color=colors, edgecolor="black")
axes[0].set_title("Completeness (%)")
axes[0].set_ylim(0, 105)

# ======================================================
# Panel 2: Contamination
# ======================================================
axes[1].bar(x, contamination, color=colors, edgecolor="black")
axes[1].set_title("Contamination (%)")

# ======================================================
# Panel 3: N50
# ======================================================
axes[2].bar(x, n50, color=colors, edgecolor="black")
axes[2].set_title("N50 (kb)")

# ======================================================
# Shared formatting + value labels
# ======================================================
for ax in axes:
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=0)

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
out = OUTDIR / "Figure8_Overall_Assembly_Quality.png"
plt.savefig(out, dpi=300, bbox_inches="tight")
plt.close()

print("✅ Figure 8 generated successfully")
print(f"📁 Output: {out}")
