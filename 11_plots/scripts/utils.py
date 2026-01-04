import os
import matplotlib.pyplot as plt

RESULTS_DIR = os.environ.get("RESULTS_DIR")
FIGURES_DIR = os.environ.get("FIGURES_DIR")

if RESULTS_DIR is None or FIGURES_DIR is None:
    raise RuntimeError("RESULTS_DIR and FIGURES_DIR must be set as environment variables")

def save_fig(name):
    for ext in ["png", "pdf"]:
        plt.savefig(
            os.path.join(FIGURES_DIR, f"{name}.{ext}"),
            dpi=300,
            bbox_inches="tight"
        )
    plt.close()
    print(f"[OK] Saved {name}.png/.pdf")
