#!/usr/bin/env python3

import os
import argparse
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
import re

# ======================================================
# CLI arguments (ENV fallback)
# ======================================================
parser = argparse.ArgumentParser(
    description="BUSCO completeness comparison plot"
)
parser.add_argument("--results", help="RESULTS_DIR")
parser.add_argument("--figures", help="FIGURES_DIR")
args = parser.parse_args()

RESULTS_DIR = args.results or os.environ.get("RESULTS_DIR")
FIGURES_DIR = args.figures or os.environ.get("FIGURES_DIR")

if RESULTS_DIR is None or FIGURES_DIR is None:
    raise RuntimeError(
        "RESULTS_DIR and FIGURES_DIR must be provided via CLI or environment"
    )

RESULTS_DIR = Path(RESULTS_DIR)
FIGURES_DIR = Path(FIGURES_DIR)
FIGURES_DIR.mkdir(parents=True, exist_ok=True)

BASE = RESULTS_DIR / "quality" / "busco"

# ======================================================
# Robust BUSCO parser
# ======================================================
def parse_busco(name: str):
    folder = BASE / name
    if not folder.exists():
        raise FileNotFoundError(f"BUSCO folder missing: {folder}")

    summaries = list(folder.rglob("short_summary*.txt"))
    if not summaries:
        raise FileNotFoundError(f"No BUSCO summary found in {folder}")

    summary = summaries[0]
    text = summary.read_text()

    m = re.search(
        r"C:(\d+\.?\d*)%.*F:(\d+\.?\d*)%.*M:(\d+\.?\d*)%",
        text,
    )

    if not m:
        raise ValueError(f"Unrecognized BUSCO format in {summary}")

    return {
        "Complete": float(m.group(1)),
        "Fragmented": float(m.group(2)),
        "Missing": float(m.group(3)),
    }

# ======================================================
# Load assemblies
# ======================================================
data = {
    "Short-read": parse_busco("short_only"),
    "Long-read":  parse_busco("long_only"),
    "Hybrid":     parse_busco("hybrid"),
}

df = pd.DataFrame(data).T

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")

colors = {
    "Complete":   "#009E73",
    "Fragmented": "#F0E442",
    "Missing":    "#D55E00",
}

fig, ax = plt.subplots(figsize=(8, 6))

df.plot(
    kind="bar",
    stacked=True,
    ax=ax,
    color=[colors[c] for c in df.columns],
    edgecolor="black",
)

# ------------------------------------------------------
# Add values
# ------------------------------------------------------
for container in ax.containers:
    for bar in container:
        h = bar.get_height()
        if h > 3:
            ax.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_y() + h / 2,
                f"{h:.1f}%",
                ha="center",
                va="center",
                fontsize=10,
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
    frameon=True,
)

# ------------------------------------------------------
# Save (FIX legend cut)
# ------------------------------------------------------
out = FIGURES_DIR / "Figure2_BUSCO_Comparison.png"
plt.savefig(out, dpi=300, bbox_inches="tight")
plt.close()

print("✅ BUSCO comparison plot generated successfully")
print(f"📁 Output: {out}")
