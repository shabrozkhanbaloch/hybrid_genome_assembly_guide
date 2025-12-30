import pandas as pd
import plotly.graph_objects as go
from pathlib import Path

BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide/06_genome_quality_assessment/coverage")

CHR_DEPTH = BASE / "long_reads/long_vs_hybrid/depth.txt"
PLASMID_DEPTH = BASE / "plasmid_vs_hybrid.depth"

# -------------------------------------------------
# Load depth file
# -------------------------------------------------
def load_depth(path, label):
    if not path.exists():
        raise FileNotFoundError(f"Missing depth file: {path}")

    df = pd.read_csv(
        path,
        sep="\t",
        header=None,
        names=["contig", "pos", "depth"]
    )
    df["Label"] = label
    return df

chr_df = load_depth(CHR_DEPTH, "Chromosome")
pl_df = load_depth(PLASMID_DEPTH, "Plasmid")

# -------------------------------------------------
# Mean coverage
# -------------------------------------------------
chr_cov = chr_df["depth"].mean()
pl_cov = pl_df["depth"].mean()
copy_number = pl_cov / chr_cov

print(f"Chromosome coverage: {chr_cov:.2f}×")
print(f"Plasmid coverage:    {pl_cov:.2f}×")
print(f"Plasmid copy number: {copy_number:.2f}")

# -------------------------------------------------
# Plot
# -------------------------------------------------
fig = go.Figure()

fig.add_trace(
    go.Box(
        y=chr_df["depth"],
        name="Chromosome",
        marker_color="#0072B2"
    )
)

fig.add_trace(
    go.Box(
        y=pl_df["depth"],
        name="Plasmid",
        marker_color="#D55E00"
    )
)

fig.update_layout(
    template="plotly_dark",
    title=(
        "Plasmid Copy Number Estimation<br>"
        f"<sup>Estimated copy number ≈ {copy_number:.2f}</sup>"
    ),
    yaxis_title="Read Depth (Coverage)",
    height=700,
    font=dict(size=14)
)

# -------------------------------------------------
# Save
# -------------------------------------------------
out = BASE / "plasmid_copy_number.html"
fig.write_html(out)

print(f"Saved: {out}")
