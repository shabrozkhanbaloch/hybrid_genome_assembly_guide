#!/bin/bash
set -euo pipefail

# ===============================
# INPUT ARGUMENT
# ===============================
RESULTS=${1:-}

if [[ -z "$RESULTS" ]]; then
  echo "Usage: cleanup_plots.sh <RESULTS_DIR>"
  exit 1
fi

FIGURES_DIR="$RESULTS/figures"

echo "=========================================="
echo " Cleaning PROJECT plots"
echo " Target: $FIGURES_DIR"
echo "=========================================="

# Safety check
[[ "$FIGURES_DIR" == */results/figures ]] || {
  echo "❌ Safety check failed: refusing to clean $FIGURES_DIR"
  exit 1
}

if [[ -d "$FIGURES_DIR" ]]; then
  echo "Removing all files in $FIGURES_DIR ..."
  rm -rf "${FIGURES_DIR:?}/"*
  echo "All project plots removed successfully."
else
  echo "Figures directory does not exist. Creating it..."
  mkdir -p "$FIGURES_DIR"
  echo "Figures directory created."
fi

echo "✅ Plot cleanup completed safely."
