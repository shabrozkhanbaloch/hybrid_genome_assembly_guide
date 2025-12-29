import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from pathlib import Path
import re

BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment")

# ======================================================
# Load CheckM2
# ======================================================
def load_checkm2(name):
    df = pd.read_csv(
        BASE / f"checkm2/{name}/quality_report.tsv",
        sep="\t"
    )
    df["Assembly"] = name.replace("_", " ").title()
    return df

checkm2 = pd.concat([
    load_checkm2("short_only"),
    load_checkm2("long_only"),
    load_checkm2("hybrid")
])

# ======================================================
# Load BUSCO
# ======================================================
def load_busco(name):
    summary = BASE / f"busco/{name}/run_bacteria_odb10/short_summary.txt"
    text = summary.read_text()

    m = re.search(r"C:(\d+\.?\d*)%.*F:(\d+\.?\d*)%.*M:(\d+\.?\d*)%", text)
    if not m:
        raise ValueError(f"BUSCO summary format not recognised in {summary}")

    return pd.DataFrame({
        "Assembly": [name.replace("_", " ").title()],
        "Complete": [float(m.group(1))],
        "Fragmented": [float(m.group(2))],
        "Missing": [float(m.group(3))]
    })

busco = pd.concat([
    load_busco("short_only"),
    load_busco("long_only"),
    load_busco("hybrid")
])

# ======================================================
# Load QUAST
# ======================================================
def load_quast(name):
    report = BASE / f"quast/{name}/report.tsv"
    df = pd.read_csv(report, sep="\t").set_index("Assembly")
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
# Dashboard Layout
# ======================================================
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=[
        "CheckM2: Completeness vs Contamination",
        "BUSCO (bacteria_odb10)",
        "QUAST: N50",
        "QUAST: Number of Contigs"
    ]
)

# ------------------------------------------------------
# Color-blind friendly palette (Okabe–Ito)
# ------------------------------------------------------
colors = {
    "Short Only": "#E69F00",   # orange
    "Long Only": "#0072B2",    # blue
    "Hybrid": "#009E73"       # green
}

# ======================================================
# CheckM2 Scatter (FIXED VISIBILITY)
# ======================================================
for _, r in checkm2.iterrows():
    x = r["Completeness_General"]
    y = r["Contamination"]

    # small jitter ONLY for short-read (visual clarity)
    if r["Assembly"] == "Short Only":
        x += 1.5
        y += 0.3

    fig.add_trace(
        go.Scatter(
            x=[x],
            y=[y],
            mode="markers",
            marker=dict(
                size=20 if r["Assembly"] == "Short Only" else 16,
                color=colors[r["Assembly"]],
                line=dict(width=2, color="white")
            ),
            text=[r["Assembly"]],
            hovertemplate=(
                "<b>%{text}</b><br>"
                "Completeness: %{x:.2f}%<br>"
                "Contamination: %{y:.2f}%<extra></extra>"
            ),
            showlegend=False
        ),
        row=1, col=1
    )

# Axis ranges (DATA-DRIVEN, NOT HARD CODED)
fig.update_xaxes(
    title="Completeness (%)",
    range=[
        checkm2["Completeness_General"].min() - 5,
        checkm2["Completeness_General"].max() + 2
    ],
    row=1, col=1
)

fig.update_yaxes(
    title="Contamination (%)",
    range=[
        0,
        checkm2["Contamination"].max() + 1
    ],
    row=1, col=1
)

# ======================================================
# BUSCO stacked bars
# ======================================================
for comp, col in zip(
    ["Complete", "Fragmented", "Missing"],
    ["#009E73", "#F0E442", "#D55E00"]
):
    fig.add_trace(
        go.Bar(
            x=busco["Assembly"],
            y=busco[comp],
            name=comp,
            marker_color=col
        ),
        row=1, col=2
    )

# ======================================================
# QUAST N50
# ======================================================
fig.add_trace(
    go.Bar(
        x=quast["Assembly"],
        y=quast["N50"],
        marker_color=[colors[a] for a in quast["Assembly"]],
        showlegend=False
    ),
    row=2, col=1
)

# ======================================================
# QUAST Contigs
# ======================================================
fig.add_trace(
    go.Bar(
        x=quast["Assembly"],
        y=quast["Contigs"],
        marker_color=[colors[a] for a in quast["Assembly"]],
        showlegend=False
    ),
    row=2, col=2
)

# ======================================================
# Global Layout (Dark mode)
# ======================================================
fig.update_layout(
    template="plotly_dark",
    height=900,
    title_text="Comparative Genome Quality Assessment (Short vs Long vs Hybrid)",
    barmode="stack",
    font=dict(size=14)
)

# ======================================================
# Save
# ======================================================
out = BASE / "genome_quality_dashboard.html"
fig.write_html(out)
print(f"Saved: {out}")
