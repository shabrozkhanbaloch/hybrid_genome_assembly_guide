#!/usr/bin/env python3

import argparse
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
import os
import sys

# ======================================================
# ARGUMENTS (CLI > ENV)
# ======================================================
parser = argparse.ArgumentParser(
    description="geNomad viral & plasmid contig classification summary"
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

GENOMAD = RESULTS / "prophage"

# ======================================================
# geNomad summary files (CONFIRMED STRUCTURE)
# ======================================================
ASM_VIRUS = GENOMAD / "assembly_level/assembly_summary/assembly_virus_summary.tsv"
ASM_PLASMID = GENOMAD / "assembly_level/assembly_summary/assembly_plasmid_summary.tsv"

PLS_VIRUS = GENOMAD / "plasmid_level/plassembler_plasmids_summary/plassembler_plasmids_virus_summary.tsv"
PLS_PLASMID = GENOMAD / "plasmid_level/plassembler_plasmids_summary/plassembler_plasmids_plasmid_summary.tsv"

files = [ASM_VIRUS, ASM_PLASMID, PLS_VIRUS, PLS_PLASMID]
for f in files:
    if not f.exists():
        sys.exit(f"❌ Missing geNomad file: {f}")

# ======================================================
# Count contigs
# ======================================================
def count_contigs(path):
    df = pd.read_csv(path, sep="\t")
    return df.shape[0]

assembly_counts = {
    "Virus": count_contigs(ASM_VIRUS),
    "Plasmid": count_contigs(ASM_PLASMID),
}

plasmid_counts = {
    "Virus": count_contigs(PLS_VIRUS),
    "Plasmid": count_contigs(PLS_PLASMID),
}

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")

colors = {
    "Virus": "#0072B2",      # blue
    "Plasmid": "#D55E00",    # vermillion
}

fig, axes = plt.subplots(1, 2, figsize=(9, 4), sharey=True)

# ---- Hybrid assembly ----
ax = axes[0]
bars = ax.bar(
    assembly_counts.keys(),
    assembly_counts.values(),
    color=[colors[k] for k in assembly_counts],
    edgecolor="black"
)
ax.set_title("Hybrid assembly")
ax.set_ylabel("Number of contigs")

for b in bars:
    ax.text(
        b.get_x() + b.get_width() / 2,
        b.get_height() + 0.5,
        str(int(b.get_height())),
        ha="center",
        fontsize=10
    )

# ---- Plasmid assembly ----
ax = axes[1]
bars = ax.bar(
    plasmid_counts.keys(),
    plasmid_counts.values(),
    color=[colors[k] for k in plasmid_counts],
    edgecolor="black"
)
ax.set_title("Plassembler plasmids")

for b in bars:
    ax.text(
        b.get_x() + b.get_width() / 2,
        b.get_height() + 0.5,
        str(int(b.get_height())),
        ha="center",
        fontsize=10
    )

# ---- Global legend ----
handles = [plt.Line2D([0], [0], color=colors[k], lw=8) for k in colors]
fig.legend(
    handles,
    colors.keys(),
    loc="upper center",
    ncol=2,
    bbox_to_anchor=(0.5, 1.08),
    frameon=True
)

fig.suptitle(
    "Figure 7. geNomad-based classification of viral and plasmid contigs",
    y=1.15
)

plt.tight_layout()

# ======================================================
# Save
# ======================================================
outfile = OUTDIR / "Figure7_geNomad_Classification.png"
plt.savefig(outfile, dpi=300, bbox_inches="tight")
plt.close()

print("✅ geNomad classification plot generated")
print(f"📁 Output: {outfile}")
