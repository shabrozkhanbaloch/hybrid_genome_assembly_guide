import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# ======================================================
# Paths
# ======================================================
BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment/quast")
OUT  = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/11_plots/figures")
OUT.mkdir(parents=True, exist_ok=True)

assemblies = {
    "Short-read": BASE / "short_only/report.tsv",
    "Long-read":  BASE / "long_only/report.tsv",
    "Hybrid":     BASE / "hybrid/report.tsv",
}

labels = []
n50 = []
contigs = []

# ======================================================
# Load QUAST data
# ======================================================
for name, path in assemblies.items():
    df = pd.read_csv(path, sep="\t").set_index("Assembly")

    labels.append(name)
    n50.append(int(df.loc["N50"].values[0]))
    contigs.append(int(df.loc["# contigs"].values[0]))

x = np.arange(len(labels))

# ======================================================
# Color-blind friendly palette (Okabe–Ito)
# ======================================================
COLOR_N50 = "#009E73"      # green
COLOR_CONTIGS = "#CC79A7" # purple

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")
fig, ax1 = plt.subplots(figsize=(8, 5))

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

# ------------------------------------------------------
# Bar labels (N50)
# ------------------------------------------------------
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

# ======================================================
# Second axis: contig count
# ======================================================
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

# Point labels
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

# ======================================================
# Title
# ======================================================
ax1.set_title("Assembly Continuity and Fragmentation (QUAST)")

# ======================================================
# LEGEND — OUTSIDE (RIGHT)
# ======================================================
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

# ======================================================
# Save
# ======================================================
plt.savefig(OUT / "quast_n50_contigs.png", dpi=300)
plt.close()

print("✅ QUAST comparison plot generated")
print("📁 Output:")
print(" - 11_plots/figures/quast_n50_contigs.png")
