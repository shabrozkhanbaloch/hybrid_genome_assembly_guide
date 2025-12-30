import pandas as pd
import plotly.express as px
from pathlib import Path
import subprocess

BASE = Path("/data/wgs_assembly/hybrid_genome_assembly_guide")
OUT = BASE / "06_genome_quality_assessment/dotplots"
OUT.mkdir(parents=True, exist_ok=True)

ASM_SHORT = BASE / "05_genome_assembly/01_short_only/assembly.fasta"
ASM_HYBRID = BASE / "05_genome_assembly/03_hybrid/assembly.fasta"
PLASMIDS = BASE / "08_plassembler/plassembler_plasmids.fasta"

# --------------------------------------------------
# Run minimap2
# --------------------------------------------------
def run_minimap(ref, qry, paf):
    cmd = ["minimap2", "-x", "asm5", str(ref), str(qry)]
    with open(paf, "w") as fh:
        subprocess.run(cmd, stdout=fh, check=True)

# --------------------------------------------------
# Convert PAF to cumulative coordinates
# --------------------------------------------------
def paf_to_df(paf):
    cols = [
        "qname","qlen","qstart","qend","strand",
        "tname","tlen","tstart","tend",
        "matches","alen","mapq"
    ]
    df = pd.read_csv(paf, sep="\t", usecols=range(12), names=cols)

    # cumulative offsets
    q_offsets = (
        df[["qname","qlen"]]
        .drop_duplicates()
        .set_index("qname")["qlen"]
        .cumsum()
        .shift(fill_value=0)
        .to_dict()
    )

    t_offsets = (
        df[["tname","tlen"]]
        .drop_duplicates()
        .set_index("tname")["tlen"]
        .cumsum()
        .shift(fill_value=0)
        .to_dict()
    )

    df["qpos"] = df["qstart"] + df["qname"].map(q_offsets)
    df["tpos"] = df["tstart"] + df["tname"].map(t_offsets)

    return df

# --------------------------------------------------
# Plot dotplot
# --------------------------------------------------
def plot_dotplot(df, title, out_html):
    fig = px.scatter(
        df,
        x="tpos",
        y="qpos",
        color="strand",
        opacity=0.4,
        labels={
            "tpos": "Hybrid genome (cumulative bp)",
            "qpos": "Query genome (cumulative bp)"
        },
        title=title
    )

    fig.update_layout(
        template="plotly_dark",
        height=800
    )

    fig.write_html(out_html)

# =========================
# Genome-level dotplot
# =========================
paf_genome = OUT / "short_vs_hybrid.paf"
run_minimap(ASM_HYBRID, ASM_SHORT, paf_genome)
df_genome = paf_to_df(paf_genome)
plot_dotplot(
    df_genome,
    "Dotplot: Short-read assembly vs Hybrid genome",
    OUT / "genome_short_vs_hybrid.html"
)

# =========================
# Plasmid-level dotplot
# =========================
paf_plasmid = OUT / "plasmid_vs_hybrid.paf"
run_minimap(ASM_HYBRID, PLASMIDS, paf_plasmid)
df_plasmid = paf_to_df(paf_plasmid)
plot_dotplot(
    df_plasmid,
    "Dotplot: Plasmids vs Hybrid genome",
    OUT / "plasmid_vs_hybrid.html"
)

print("Dotplots with visible alignments generated in:", OUT)
