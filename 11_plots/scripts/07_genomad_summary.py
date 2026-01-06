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
# Assembly-level summaries (STABLE)
# ======================================================
ASM_SUMMARY = GENOMAD / "assembly_level" / "assembly_summary"

ASM_VIRUS = ASM_SUMMARY / "assembly_virus_summary.tsv"
ASM_PLASMID = ASM_SUMMARY / "assembly_plasmid_summary.tsv"

for f in (ASM_VIRUS, ASM_PLASMID):
    if not f.exists():
        sys.exit(f"❌ Missing geNomad file: {f}")

# ======================================================
# Plasmid-level summaries (ROBUST DISCOVERY)
# ======================================================
PLASMID_SUMMARY_DIRS = list(
    (GENOMAD / "plasmid_level").glob(
        "*/plassembler_plasmids_summary"
    )
)

if not PLASMID_SUMMARY_DIRS:
    sys.exit("❌ No plassembler_plasmids_summary folders found")

# ======================================================
# Helper
# ======================================================
def count_contigs(path):
    df = pd.read_csv(path, sep="\t")
    return df.shape[0]

# ======================================================
# Assembly counts
# ======================================================
assembly_counts = {
    "Virus": count_contigs(ASM_VIRUS),
    "Plasmid": count_contigs(ASM_PLASMID),
}

# ======================================================
# Plasmid counts (SUM across all plasmid FASTAs)
# ======================================================
plasmid_virus = 0
plasmid_plasmid = 0

for d in PLASMID_SUMMARY_DIRS:
    v = d / "plassembler_plasmids_virus_summary.tsv"
    p = d / "plassembler_plasmids_plasmid_summary.tsv"

    if v.exists():
        plasmid_virus += count_contigs(v)
    if p.exists():
        plasmid_plasmid += count_contigs(p)

plasmid_counts = {
    "Virus": plasmid_virus,
    "Plasmid": plasmid_plasmid,
}

# ======================================================
# Plot
# ======================================================
plt.style.use("seaborn-v0_8-whitegrid")

colors = {
    "Virus": "#0072B2",
    "Plasmid": "#D55E00",
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
        int(b.get_height()),
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
        int(b.get_height()),
        ha="center",
        fontsize=10
    )

# ---- Legend ----
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
