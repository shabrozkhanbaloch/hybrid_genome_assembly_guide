OKABE_ITO = {
    "black": "#000000",
    "orange": "#E69F00",
    "skyblue": "#56B4E9",
    "bluishgreen": "#009E73",
    "yellow": "#F0E442",
    "blue": "#0072B2",
    "vermillion": "#D55E00",
    "reddishpurple": "#CC79A7"
}

import matplotlib as mpl

def set_nature_style():
    mpl.rcParams.update({
        "figure.figsize": (6,4),
        "figure.dpi": 300,
        "font.family": "sans-serif",
        "font.sans-serif": ["Arial","Helvetica","DejaVu Sans"],
        "axes.linewidth": 1.2,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.labelsize": 11,
        "axes.titlesize": 12,
        "xtick.labelsize": 10,
        "ytick.labelsize": 10,
        "legend.frameon": False,
        "legend.fontsize": 9
    })
