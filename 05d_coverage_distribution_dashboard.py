import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from pathlib import Path

BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment/coverage")

def find_depth_file(parent):
    # go one level deeper and pick first file
    for sub in parent.iterdir():
        if sub.is_dir():
            files = list(sub.glob("*"))
            if files:
                return files[0]
    raise FileNotFoundError(f"No depth file found under {parent}")

FILES = {
    "Short reads → Hybrid": find_depth_file(BASE / "short_reads"),
    "Long reads → Hybrid":  find_depth_file(BASE / "long_reads"),
}

# -------------------------------
# Load coverage data
# -------------------------------
dfs = []
for label, file in FILES.items():
    df = pd.read_csv(
        file,
        sep="\t",
        header=None,
        names=["Contig", "Position", "Coverage"]
    )
    df["Comparison"] = label
    dfs.append(df)

cov = pd.concat(dfs, ignore_index=True)

# cap extreme coverage for visibility
cov["Coverage_capped"] = cov["Coverage"].clip(upper=500)

# -------------------------------
# Color-blind friendly palette
# -------------------------------
colors = {
    "Short reads → Hybrid": "#E69F00",  # orange
    "Long reads → Hybrid":  "#0072B2",  # blue
}

# -------------------------------
# Plot
# -------------------------------
fig = make_subplots(
    rows=1, cols=2,
    subplot_titles=[
        "Coverage Distribution (Violin)",
        "Coverage Distribution (Boxplot)"
    ]
)

for name, grp in cov.groupby("Comparison"):
    fig.add_trace(
        go.Violin(
            y=grp["Coverage_capped"],
            name=name,
            box_visible=True,
            meanline_visible=True,
            fillcolor=colors[name],
            line_color=colors[name],
            opacity=0.75,
            showlegend=False
        ),
        row=1, col=1
    )

for name, grp in cov.groupby("Comparison"):
    fig.add_trace(
        go.Box(
            y=grp["Coverage_capped"],
            name=name,
            marker_color=colors[name],
            boxmean=True,
            showlegend=False
        ),
        row=1, col=2
    )

fig.update_layout(
    template="plotly_dark",
    height=650,
    title="Coverage Distribution: Short vs Long Reads on Hybrid Assembly",
    yaxis_title="Coverage depth (capped at 500×)",
    font=dict(size=14)
)

out = BASE / "coverage_dashboard.html"
fig.write_html(out)
print(f"Saved: {out}")
