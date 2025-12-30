import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from pathlib import Path
import re

BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment")

# ======================================================
# Colors (Okabe–Ito, color-blind safe)
# ======================================================
COLORS = {
    "Short Only": "#E69F00",
    "Long Only": "#0072B2",
    "Hybrid": "#009E73",
    "Complete": "#009E73",
    "Fragmented": "#F0E442",
    "Missing": "#D55E00"
}

# ======================================================
# CheckM2
# ======================================================
def load_checkm2(name):
    df = pd.read_csv(BASE / f"checkm2/{name}/quality_report.tsv", sep="\t")
    df["Assembly"] = name.replace("_", " ").title()
    return df

checkm2 = pd.concat([
    load_checkm2("short_only"),
    load_checkm2("long_only"),
    load_checkm2("hybrid")
])

# ======================================================
# BUSCO
# ======================================================
def load_busco(name):
    txt = (BASE / f"busco/{name}/run_bacteria_odb10/short_summary.txt").read_text()
    m = re.search(r"C:(\d+\.?\d*)%.*F:(\d+\.?\d*)%.*M:(\d+\.?\d*)%", txt)
    return {
        "Assembly": name.replace("_", " ").title(),
        "Complete": float(m.group(1)),
        "Fragmented": float(m.group(2)),
        "Missing": float(m.group(3))
    }

busco = pd.DataFrame([
    load_busco("short_only"),
    load_busco("long_only"),
    load_busco("hybrid")
])

# ======================================================
# QUAST
# ======================================================
def load_quast(name):
    df = pd.read_csv(BASE / f"quast/{name}/report.tsv", sep="\t").set_index("Assembly")
    return {
        "Assembly": name.replace("_", " ").title(),
        "N50": int(df.loc["N50"].values[0]),
        "Contigs": int(df.loc["# contigs"].values[0])
    }

quast = pd.DataFrame([
    load_quast("short_only"),
    load_quast("long_only"),
    load_quast("hybrid")
])

# ======================================================
# Coverage distributions
# ======================================================
def load_depth(path, label):
    df = pd.read_csv(path, sep="\t", names=["contig", "pos", "depth"])
    df["Dataset"] = label
    return df

coverage = pd.concat([
    load_depth(BASE / "coverage/short_reads/short_vs_hybrid/depth.txt", "Short → Hybrid"),
    load_depth(BASE / "coverage/long_reads/long_vs_hybrid/depth.txt", "Long → Hybrid")
])

# ======================================================
# Plasmid copy number
# ======================================================
chr = pd.read_csv(BASE / "coverage/long_reads/long_vs_hybrid/depth.txt",
                  sep="\t", names=["c","p","d"])
pl = pd.read_csv(BASE / "coverage/plasmid_vs_hybrid.depth",
                 sep="\t", names=["c","p","d"])

copy_number = pl["d"].mean() / chr["d"].mean()

# ======================================================
# DASHBOARD
# ======================================================
fig = make_subplots(
    rows=3, cols=2,
    subplot_titles=[
        "CheckM2: Completeness vs Contamination",
        "BUSCO (bacteria_odb10)",
        "QUAST: N50",
        "QUAST: Contigs",
        "Coverage distribution",
        "Plasmid copy number"
    ],
    specs=[
        [{}, {}],
        [{}, {}],
        [{"colspan": 2}, None]
    ]
)

# ---- CheckM2
for _, r in checkm2.iterrows():
    fig.add_trace(go.Scatter(
        x=[r["Completeness_General"]],
        y=[r["Contamination"]],
        mode="markers",
        marker=dict(size=18, color=COLORS[r["Assembly"]],
                    line=dict(color="white", width=2)),
        hovertemplate=f"<b>{r['Assembly']}</b><br>Completeness: %{{x:.2f}}%<br>Contamination: %{{y:.2f}}%<extra></extra>",
        showlegend=False
    ), row=1, col=1)

# ---- BUSCO
for comp in ["Complete", "Fragmented", "Missing"]:
    fig.add_trace(go.Bar(
        x=busco["Assembly"],
        y=busco[comp],
        name=comp,
        marker_color=COLORS[comp]
    ), row=1, col=2)

# ---- QUAST
fig.add_trace(go.Bar(
    x=quast["Assembly"],
    y=quast["N50"],
    marker_color=[COLORS[a] for a in quast["Assembly"]],
    showlegend=False
), row=2, col=1)

fig.add_trace(go.Bar(
    x=quast["Assembly"],
    y=quast["Contigs"],
    marker_color=[COLORS[a] for a in quast["Assembly"]],
    showlegend=False
), row=2, col=2)

# ---- Coverage
for lab in coverage["Dataset"].unique():
    fig.add_trace(go.Violin(
        y=coverage[coverage["Dataset"] == lab]["depth"],
        name=lab,
        box_visible=True,
        meanline_visible=True
    ), row=3, col=1)

# ---- Copy number
fig.add_annotation(
    x=0.5,
    y=0.15,
    xref="paper",
    yref="paper",
    text=(
        f"<b>Estimated plasmid copy number</b><br>"
        f"{copy_number:.2f}× (relative to chromosome)"
    ),
    showarrow=False,
    font=dict(size=18, color="white"),
    align="center",
    bgcolor="rgba(0,0,0,0.6)",
    bordercolor="white",
    borderwidth=1
)

# ======================================================
# Layout
# ======================================================
fig.update_layout(
    template="plotly_dark",
    height=1200,
    title_text="Final Genome Quality Assessment Dashboard",
    barmode="stack",
    font=dict(size=14)
)

out = BASE / "final_genome_quality_dashboard.html"
fig.write_html(out)
print(f"FINAL DASHBOARD SAVED → {out}")
