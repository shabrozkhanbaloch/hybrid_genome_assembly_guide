#!/usr/bin/env python3

import subprocess
import pandas as pd
from pathlib import Path
from Bio import SeqIO
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# ======================================================
# Paths
# ======================================================
BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide")

ASM_SHORT   = BASE / "05_genome_assembly/01_short_only/assembly.fasta"
ASM_HYBRID  = BASE / "05_genome_assembly/03_hybrid/assembly.fasta"

READS_SHORT = BASE / "03_processed_reads/short_reads/processed_1.fastq.gz"
READS_LONG  = BASE / "03_processed_reads/long_reads/processed_long.fastq.gz"

OUTDIR = BASE / "06_genome_quality_assessment/gc_bias"
OUTDIR.mkdir(parents=True, exist_ok=True)

# ======================================================
# Helpers
# ======================================================
def run_mapping(assembly, reads, bam_out, preset):
    cmd = (
        f"minimap2 -ax {preset} {assembly} {reads} | "
        f"samtools sort -o {bam_out}"
    )
    subprocess.run(cmd, shell=True, check=True)
    subprocess.run(f"samtools index {bam_out}", shell=True, check=True)

def compute_gc(fasta):
    gc = {}
    for rec in SeqIO.parse(fasta, "fasta"):
        seq = rec.seq.upper()
        gc[rec.id] = 100 * (seq.count("G") + seq.count("C")) / len(seq)
    return gc

def compute_coverage(bam):
    cmd = f"samtools depth {bam}"
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)

    cov = {}
    for line in p.stdout:
        contig, _, depth = line.strip().split()
        cov.setdefault(contig, []).append(int(depth))

    return {k: sum(v) / len(v) for k, v in cov.items()}

def build_df(fasta, bam):
    gc = compute_gc(fasta)
    cov = compute_coverage(bam)

    rows = []
    for contig in gc:
        if contig in cov:
            rows.append({
                "GC": gc[contig],
                "Coverage": cov[contig]
            })
    return pd.DataFrame(rows)

# ======================================================
# Mapping (run once)
# ======================================================
bam_short_short  = OUTDIR / "short_vs_short.bam"
bam_short_hybrid = OUTDIR / "short_vs_hybrid.bam"
bam_long_hybrid  = OUTDIR / "long_vs_hybrid.bam"

run_mapping(ASM_SHORT,  READS_SHORT, bam_short_short,  "sr")
run_mapping(ASM_HYBRID, READS_SHORT, bam_short_hybrid, "sr")
run_mapping(ASM_HYBRID, READS_LONG,  bam_long_hybrid,  "map-ont")

# ======================================================
# Data
# ======================================================
df_ss = build_df(ASM_SHORT,  bam_short_short)
df_sh = build_df(ASM_HYBRID, bam_short_hybrid)
df_lh = build_df(ASM_HYBRID, bam_long_hybrid)

# ======================================================
# Dashboard (single page)
# ======================================================
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=[
        "Short reads → Short assembly",
        "Short reads → Hybrid assembly",
        "Long reads → Hybrid assembly",
        ""
    ]
)

fig.add_trace(
    go.Scatter(
        x=df_ss["GC"], y=df_ss["Coverage"],
        mode="markers",
        marker=dict(color="#E69F00", size=5),
        showlegend=False
    ),
    row=1, col=1
)

fig.add_trace(
    go.Scatter(
        x=df_sh["GC"], y=df_sh["Coverage"],
        mode="markers",
        marker=dict(color="#0072B2", size=5),
        showlegend=False
    ),
    row=1, col=2
)

fig.add_trace(
    go.Scatter(
        x=df_lh["GC"], y=df_lh["Coverage"],
        mode="markers",
        marker=dict(color="#009E73", size=5),
        showlegend=False
    ),
    row=2, col=1
)

fig.update_layout(
    template="plotly_dark",
    height=900,
    title="GC Bias Analysis Across Assemblies",
    font=dict(size=14)
)

fig.update_xaxes(title="GC content (%)")
fig.update_yaxes(title="Coverage (X)")

# ======================================================
# Save
# ======================================================
out = OUTDIR / "gc_bias_dashboard.html"
fig.write_html(out)
print(f"Saved: {out}")
