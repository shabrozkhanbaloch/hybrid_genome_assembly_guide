from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

# --------------------------------------------------
# Project root (robust)
# --------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parents[2]
COVERAGE = PROJECT_ROOT / "06_genome_quality_assessment" / "coverage"

# --------------------------------------------------
# Coverage folders
# --------------------------------------------------
folders = {
    "Short vs Short": COVERAGE / "short_reads" / "short_vs_short",
    "Short vs Hybrid": COVERAGE / "short_reads" / "short_vs_hybrid",
    "Long vs Hybrid": COVERAGE / "long_reads" / "long_vs_hybrid",
}

depth_data = {}

# --------------------------------------------------
# Auto-detect depth file
# --------------------------------------------------
for label, folder in folders.items():
    if not folder.exists():
        raise FileNotFoundError(f"Folder missing: {folder}")

    candidates = list(folder.glob("*depth*.txt")) + list(folder.glob("*depth*.tsv"))

    if not candidates:
        print(f"\nDEBUG: files in {folder}")
        for f in folder.iterdir():
            print(" -", f.name)
        raise FileNotFoundError(f"No depth file found in {folder}")

    depth_file = candidates[0]

    df = pd.read_csv(depth_file, sep="\t", header=None)
    df.columns = ["contig", "position", "depth"]
    depth_data[label] = df["depth"]

# --------------------------------------------------
# Plot
# --------------------------------------------------
plt.figure(figsize=(10, 6))

for label, depths in depth_data.items():
    plt.hist(
        depths,
        bins=120,
        density=True,
        alpha=0.6,
        label=label
    )

plt.xlabel("Coverage depth")
plt.ylabel("Density")
plt.title("Figure 5. Coverage Depth Distribution Comparison")
plt.legend(frameon=False)
plt.tight_layout()

# --------------------------------------------------
# Save
# --------------------------------------------------
outdir = PROJECT_ROOT / "11_plots" / "figures"
outdir.mkdir(parents=True, exist_ok=True)

plt.savefig(outdir / "Figure5_Coverage_Depth_Distribution.png", dpi=300)
plt.show()
