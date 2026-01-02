import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# ======================================================
# Paths
# ======================================================
BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment/checkm2")
OUT  = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/11_plots/figures")
OUT.mkdir(parents=True, exist_ok=True)

assemblies = {
    "Short-read": BASE / "short_only/quality_report.tsv",
    "Long-read":  BASE / "long_only/quality_report.tsv",
    "Hybrid":     BASE / "hybrid/quality_report.tsv",
}

labels = []
completeness = []
contamination = []

# ======================================================
# Load data
# ======================================================
for name, path in assemblies.items():
    df = pd.read_csv(path, sep="\t")
    labels.append(name)
    completeness.append(float(df.loc[0, "Completeness_General"]))
    contamination.append(float(df.loc[0, "Contamination"]))

x = np.arange(len(labels))

# ======================================================
# Color-blind friendly palette (Okabe–Ito)
# ======================================================
COLOR_COMPLETENESS = "#0072B2"   # blue
COLOR_CONTAM       = "#D55E00"   # vermillion

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")
fig, ax1 = plt.subplots(figsize=(8, 5))

bars = ax1.bar(
    x,
    completeness,
    width=0.6,
    color=COLOR_COMPLETENESS,
    edgecolor="black",
    label="Completeness (%)"
)

ax1.set_ylabel("Completeness (%)")
ax1.set_ylim(0, 105)
ax1.set_xticks(x)
ax1.set_xticklabels(labels)

# ------------------------------------------------------
# Bar labels
# ------------------------------------------------------
for bar in bars:
    h = bar.get_height()
    ax1.text(
        bar.get_x() + bar.get_width() / 2,
        h + 1,
        f"{h:.1f}%",
        ha="center",
        va="bottom",
        fontsize=10
    )

# ======================================================
# Second axis: contamination
# ======================================================
ax2 = ax1.twinx()
line = ax2.plot(
    x,
    contamination,
    color=COLOR_CONTAM,
    marker="o",
    linewidth=2,
    label="Contamination (%)"
)

ax2.set_ylabel("Contamination (%)")
ax2.set_ylim(0, max(contamination) + 1)

# Point labels
for xi, yi in zip(x, contamination):
    ax2.text(
        xi,
        yi + 0.12,
        f"{yi:.2f}%",
        color=COLOR_CONTAM,
        ha="center",
        va="bottom",
        fontsize=9
    )

# ======================================================
# Title
# ======================================================
ax1.set_title("Assembly Quality Comparison (CheckM2)")

# ======================================================
# LEGEND — OUTSIDE (RIGHT)
# ======================================================
handles = [bars[0], line[0]]
labels_leg = ["Completeness (%)", "Contamination (%)"]

ax1.legend(
    handles,
    labels_leg,
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True
)

plt.tight_layout()

# ======================================================
# Save
# ======================================================
plt.savefig(OUT / "Figure1_checkm2_completeness_contamination.png", dpi=300)
plt.close()

print("✅ CheckM2 comparison plot generated")
print("📁 Output:")
print(" - 11_plots/figures/Figure1_checkm2_completeness_contamination.png")

