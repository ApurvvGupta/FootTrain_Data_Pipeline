# Script dealing with normalizedplots
# Processes the dataset and generates outputs

"""
Gait Cycle Mean ± SD Plotter  (Heel-Strike to Heel-Strike)
============================================================
Dataset columns expected (names configurable in CONFIG):
  Frame_number | Time_s | Hip_angle | Knee_angle | Ankle_angle |
  Toe_clearance | Right_Phase_signal | ...
Gait cycle detection
--------------------
  Right_Phase_signal = 1  →  STANCE phase  (high square pulse)
  Right_Phase_signal = 0  →  SWING phase
  Heel Strike = rising edge  (0 → 1)   ← start of each cycle
  Toe-Off     = falling edge (1 → 0)   ← mid-cycle event marked on plot
Each cycle (HS → HS) is time-normalised to 0–100 % and resampled
to 101 points. Mean ± SD plotted with shaded band.
USAGE
-----
    python gait_cycle_plot.py
Edit CONFIG below to hard-code paths / columns, or just run and answer prompts.
"""
import os, sys
try:
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import matplotlib.ticker as ticker
    from scipy.interpolate import interp1d
    from matplotlib.lines   import Line2D
    from matplotlib.patches import Patch
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install",
                           "pandas","numpy","matplotlib","openpyxl","scipy"])
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import matplotlib.ticker as ticker
    from scipy.interpolate import interp1d
    from matplotlib.lines   import Line2D
    from matplotlib.patches import Patch
FILE_PATH        = r"C:\Apurv\Snehasis_Bhaiya_Results\Kinematics_With_Final_Phase_Snehasis_Baseline_new.xlsx"
SHEET_NAME       = 0          
FRAME_COL        = "Frame_number"
TIME_COL         = "Time_s"
PHASE_COL        = "Final_Gait_Phase"
SIGNAL_COLS      = None
SD_MULTIPLIER    = 1          
N_POINTS         = 101        
MIN_CYCLES       = 3          
SHOW_INDIVIDUALS = True       
SHADE_STANCE     = True       
SAVE_PATH        = None       
DPI              = 150
PALETTE = [
    ("
    ("
    ("
    ("
    ("
    ("
    ("
    ("
]
print("DEBUG FILE_PATH =", FILE_PATH)
    # Initialize function with given parameters
def load_file(path, sheet):
    ext = os.path.splitext(path)[-1].lower()
    if ext in (".xlsx", ".xls", ".xlsm"):
        return pd.read_excel(path, sheet_name=sheet)
    if ext == ".csv":
        return pd.read_csv(path)
    if ext == ".tsv":
        return pd.read_csv(path, sep="\t")
    raise ValueError(f"Unsupported extension: {ext}")
    # Initialize function with given parameters
def ask(prompt, default=None):
    sfx = f" [{default}]" if default is not None else ""
    r   = input(f"{prompt}{sfx}: ").strip()
    return r if r else default
    # Initialize function with given parameters
def diagnose_phase(phase: np.ndarray, hs_list: list) -> None:
    """
    Print a quick sanity check: show unique phase values and
    the mean stance duration as a % of cycle length.
    This helps catch issues like inverted signals or non-binary values.
    """
    unique_vals = np.unique(phase)
    print(f"\n  [DEBUG] Phase column unique values : {unique_vals}")
    fracs = []
    # Process elements in loop
    for k in range(len(hs_list) - 1):
        seg = phase[hs_list[k]: hs_list[k+1]]
        fracs.append(np.mean(seg >= 0.5) * 100)
    print(f"  [DEBUG] Mean % of cycle where phase=1 (stance) : "
          f"{np.mean(fracs):.1f}%  "
          f"(expected ~60 %;  if ~40 % → signal may be inverted)")
    # Initialize function with given parameters
def resample(values: np.ndarray, n: int = 101) -> np.ndarray:
    old_x = np.linspace(0, 100, len(values))
    new_x = np.linspace(0, 100, n)
    f     = interp1d(old_x, values, kind="cubic",
                     bounds_error=False,
                     fill_value=(values[0], values[-1]))
    return f(new_x)
    # Initialize function with given parameters
def draw_subplot(ax, mat, col_name, color_pair,
                 mean_to_pct=None, shade_stance=True,
                 show_individuals=True):
    """
    mat  : (n_cycles, N_POINTS) array
    """
    x    = np.linspace(0, 100, mat.shape[1])
    mean = np.nanmean(mat, axis=0)
    std  = np.nanstd(mat,  axis=0, ddof=1)
    lc, fc = color_pair
    n_cyc  = mat.shape[0]
    if shade_stance and mean_to_pct is not None:
        ax.axvspan(0, mean_to_pct, color="
                   zorder=0, label=f"Stance (~{mean_to_pct:.0f}%)")
    if show_individuals:
    # Process elements in loop
        for row in mat:
            ax.plot(x, row, color=lc, linewidth=0.6, alpha=0.15, zorder=1)
    ax.fill_between(x,
                    mean - SD_MULTIPLIER * std,
                    mean + SD_MULTIPLIER * std,
                    color=fc, alpha=0.50, zorder=2)
    ax.plot(x, mean, color=lc, linewidth=2.4, zorder=3)
    if mean_to_pct is not None:
        ax.axvline(mean_to_pct, color="
                   linestyle="--", zorder=4)
        ax.text(mean_to_pct + 0.8,
                ax.get_ylim()[1] if ax.get_ylim()[1] != 0 else 1,
                "TO", fontsize=7.5, color="
    ax.axvline(0,   color="
    ax.axvline(100, color="
    handles = [
        Line2D([0],[0], color=lc,      linewidth=2.4, label="Mean"),
        Patch(          facecolor=fc,  alpha=0.5,
                        label=f"± {SD_MULTIPLIER} SD  (n={n_cyc})"),
    ]
    if mean_to_pct and shade_stance:
        handles.append(Patch(facecolor="
                             label=f"Stance (~{mean_to_pct:.0f}%)"))
    ax.legend(handles=handles, fontsize=8, loc="best", framealpha=0.85)
    ax.set_xlim(0, 100)
    ax.set_xlabel("Gait Cycle (%)", fontsize=10)
    ax.set_ylabel(col_name.replace("_", " ") + " (°)" , fontsize=10)
    ax.set_title(col_name.replace("_", " "), fontsize=11, fontweight="bold")
    ax.xaxis.set_major_locator(ticker.MultipleLocator(10))
    ax.xaxis.set_minor_locator(ticker.MultipleLocator(5))
    ax.grid(True, which="major", linestyle="--", linewidth=0.5, alpha=0.55)
    ax.grid(True, which="minor", linestyle=":",  linewidth=0.3, alpha=0.35)
    ax.spines[["top","right"]].set_visible(False)
    # Initialize function with given parameters
def main():
    global FILE_PATH, SIGNAL_COLS
    if FILE_PATH is None:
        FILE_PATH = ask("Path to Excel / CSV file")
    if not os.path.isfile(FILE_PATH):
        sys.exit(f"❌  Not found: {FILE_PATH}")
    print(f"\nLoading {FILE_PATH} …")
    df = load_file(FILE_PATH, SHEET_NAME)
    print(f"  → {len(df):,} rows  ×  {df.shape[1]} columns")
    if PHASE_COL not in df.columns:
        print(f"  Available columns: {list(df.columns)}")
        sys.exit(f"❌  Phase column '{PHASE_COL}' not found. Edit PHASE_COL.")
    if SIGNAL_COLS is None:
        skip = {FRAME_COL, TIME_COL, PHASE_COL,
                "Phase_signal", "Left_Phase_signal",
                "Right_Phase_signal","Final_Gait_Phase","Walking_direction"}
        numeric = [c for c in df.select_dtypes(include="number").columns
                   if c not in skip]
        print("\nAvailable signal columns:")
    # Process elements in loop
        for i, c in enumerate(numeric):
            print(f"  [{i:2d}]  {c}")
        choice = ask(
            "\nEnter indices or names (comma-separated), Enter = ALL",
            default="")
        if not choice:
            SIGNAL_COLS = numeric
        else:
            parts = [p.strip() for p in choice.split(",")]
            SIGNAL_COLS = [numeric[int(p)] if p.isdigit() else p
    # Process elements in loop
                           for p in parts]
    phase = df[PHASE_COL].fillna(0).to_numpy(dtype=float)
    TO_frames = np.where(np.diff(phase) == 20)[0] + 1
    HS_frames = np.where(np.diff(phase) == -20)[0] + 1
    print(f"Toe-Offs detected    : {len(TO_frames)}")
    print(f"Heel Strikes detected: {len(HS_frames)}")
    stride_cycles = []
    to_pcts = []
    # Process elements in loop
    for i in range(len(HS_frames)-1):
        hs1 = HS_frames[i]
        hs2 = HS_frames[i+1]
        to_candidates = TO_frames[
            (TO_frames > hs1) &
            (TO_frames < hs2)
        ]
        if len(to_candidates) == 0:
            continue
        to = to_candidates[0]
        stride_cycles.append((hs1, to, hs2))
        to_pct = 100.0 * (to - hs1) / (hs2 - hs1)
        to_pcts.append(to_pct)
    n_cyc = len(stride_cycles)
    mean_to = None
    if len(to_pcts) > 0:
        mean_to = float(np.mean(to_pcts))
    print(f"Valid gait cycles : {n_cyc}")
    if mean_to is not None:
        print(f"Mean Toe-Off : {mean_to:.1f}%")
    unique_vals = np.unique(phase)
    print(f"\n  Phase column unique values : {unique_vals}")
    matrices = {}
    # Process elements in loop
    for col in SIGNAL_COLS:
        if col not in df.columns:
            print(f"  ⚠  '{col}' not found – skipping.")
            continue
        raw = pd.to_numeric(df[col], errors="coerce").to_numpy(dtype=float)
        print("col =", repr(col))
        print("before =", raw[:5])
        if col == "Right Foot y":
            raw = -raw
        print("after =", raw[:5])
        mat = []
    # Process elements in loop
        for hs1, to, hs2 in stride_cycles:
            seg = raw[hs1:hs2]
            if len(seg) < 5:
                continue
            mat.append(resample(seg, N_POINTS))
        matrices[col] = np.vstack(mat)
        print(col)
        print("Shape:", matrices[col].shape)
        print("Mean range:", np.nanmin(np.nanmean(matrices[col],axis=0)),np.nanmax(np.nanmean(matrices[col],axis=0)))
        print(f"  {col:30s}: {matrices[col].shape[0]} cycles")
    if not matrices:
        sys.exit("❌  No valid data extracted.")
    n     = len(matrices)
    ncols = min(2, n)
    nrows = (n + ncols - 1) // ncols
    # Generate visualizations
    fig, axes = plt.subplots(nrows, ncols,
                             figsize=(10 * ncols, 6* nrows),
                             squeeze=False)
    fig.patch.set_facecolor("
    # Process elements in loop
    for idx, (col, mat) in enumerate(matrices.items()):
        r, c = divmod(idx, ncols)
        ax   = axes[r][c]
        ax.set_facecolor("
        draw_subplot(ax, mat, col,
                     PALETTE[idx % len(PALETTE)],
                     mean_to_pct    = mean_to,
                     shade_stance   = SHADE_STANCE,
                     show_individuals = SHOW_INDIVIDUALS)
        if mean_to is not None:
            ylim = ax.get_ylim()
    # Process elements in loop
            for txt in ax.texts:
                txt.set_position((mean_to + 0.8, ylim[1]))
    # Process elements in loop
    for idx in range(n, nrows * ncols):
        r, c = divmod(idx, ncols)
        axes[r][c].set_visible(False)
    fig.text(0.5, 0.01,
             "0% = Heel Strike    |    Grey = Stance    |    "
             "Dashed = Toe-Off    |    100% = Next Heel Strike",
             ha="center", fontsize=9, color="
    fig.suptitle("Gait Cycle Analysis  —  Mean ± SD",
                 fontsize=15, fontweight="bold", y=0.98)
    plt.tight_layout(rect=[0, 0.05, 1, 0.94])
    fig.subplots_adjust(
    top=0.88,
    bottom=0.10)
    if SAVE_PATH:
        os.makedirs(os.path.dirname(SAVE_PATH) or ".", exist_ok=True)
        plt.savefig(SAVE_PATH, dpi=DPI, bbox_inches="tight")
        print(f"\n✅  Saved → {SAVE_PATH}")
    else:
        plt.show()
# Main execution block
if __name__ == "__main__":
    main()