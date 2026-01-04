import os
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
import re

# ======================================================
# Environment-aware paths
# ======================================================
RESULTS_DIR = os.environ.get("RESULTS_DIR")
FIGURES_DIR = os.environ.get("FIGURES_DIR")

if RESULTS_DIR is None or FIGURES_DIR is None:
    raise RuntimeError("RESULTS_DIR and FIGURES_DIR must be set")

BASE = Path(RESULTS_DIR) / "quality" / "busco"
OUT  = Path(FIGURES_DIR)
OUT.mkdir(parents=True, exist_ok=True)

# ======================================================
# Robust BUSCO parser
# ======================================================
def parse_busco(name):
    """
    Works for BUSCO v4 / v5 outputs
    """
    # Auto-detect summary file
    candidates = list((BASE / name).rglob("short_summary*.txt"))
    if not candidates:
        raise FileNotFoundError(f"No BUSCO summary found for {name}")

    summary = candidates[0]
    text = summary.read_text()

    m = re.search(
        r"C:(\d+\.?\d*)%.*F:(\d+\.?\d*)%.*M:(\d+\.?\d*)%",
        text
    )

    if not m:
        raise ValueError(f"BUSCO format not recognised in {summary}")

    return {
        "Complete":   float(m.group(1)),
        "Fragmented": float(m.group(2)),
        "Missing":    float(m.group(3))
    }

# ======================================================
# Load all assemblies
# ======================================================
data = {
    "Short-read": parse_busco("short_only"),
    "Long-read":  parse_busco("long_only"),
    "Hybrid":     parse_busco("hybrid")
}

df = pd.DataFrame(data).T

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")

colors = {
    "Complete":   "#009E73",  # green
    "Fragmented": "#F0E442",  # yellow
    "Missing":    "#D55E00"   # red
}

ax = df.plot(
    kind="bar",
    stacked=True,
    figsize=(8, 6),
    color=[colors[c] for c in df.columns],
    edgecolor="black"
)

# ------------------------------------------------------
# Add values on bars
# ------------------------------------------------------
for container in ax.containers:
    for bar in container:
        height = bar.get_height()
        if height > 3:
            ax.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_y() + height / 2,
                f"{height:.1f}%",
                ha="center",
                va="center",
                fontsize=10,
                color="black"
            )

# ------------------------------------------------------
# Labels & legend
# ------------------------------------------------------
ax.set_ylabel("Percentage of BUSCO genes (%)")
ax.set_xlabel("")
ax.set_title("BUSCO completeness comparison (bacteria_odb10)")

ax.legend(
    title="BUSCO category",
    bbox_to_anchor=(1.02, 1),
    loc="upper left",
    frameon=True
)

plt.tight_layout()

# ======================================================
# Save
# ======================================================
plt.savefig(OUT / "Figure2_BUSCO_Comparison.png", dpi=300)
plt.close()

print("✅ BUSCO comparison plot generated successfully")
print(f"📁 Output: {OUT}")
