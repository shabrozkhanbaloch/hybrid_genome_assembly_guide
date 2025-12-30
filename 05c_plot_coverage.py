import pandas as pd
import plotly.graph_objects as go
from pathlib import Path

BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment/coverage")

FILES = {
    "Short → Short": BASE / "short_reads/short_vs_short/depth.txt",
    "Short → Hybrid": BASE / "short_reads/short_vs_hybrid/depth.txt",
    "Long → Hybrid": BASE / "long_reads/long_vs_hybrid/depth.txt",
}

def load_depth(path):
    df = pd.read_csv(path, sep="\t", header=None, names=["contig", "pos", "depth"])
    return df["depth"]

stats = []
for label, path in FILES.items():
    d = load_depth(path)
    stats.append({
        "Assembly": label,
        "Mean depth": d.mean(),
        "Median depth": d.median()
    })

stats_df = pd.DataFrame(stats)

# ----------------------------------
# Plot (color-blind + dark mode)
# ----------------------------------
fig = go.Figure()

fig.add_trace(go.Bar(
    x=stats_df["Assembly"],
    y=stats_df["Mean depth"],
    name="Mean depth",
    marker_color="#56B4E9"
))

fig.add_trace(go.Bar(
    x=stats_df["Assembly"],
    y=stats_df["Median depth"],
    name="Median depth",
    marker_color="#E69F00"
))

fig.update_layout(
    template="plotly_dark",
    title="Read Coverage Comparison (Short vs Hybrid)",
    yaxis_title="Coverage (X)",
    barmode="group",
    height=600,
    font=dict(size=14)
)

out = BASE / "coverage_comparison.html"
fig.write_html(out)

print("Coverage plot saved to:")
print(out)
