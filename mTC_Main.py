# Script dealing with mTC Main
# Processes the dataset and generates outputs

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks
file_path = r"C:\FPA_DP\Ritam_Feedback_CA_Right_Final_Gait_Phase.xlsx"
df = pd.read_excel(file_path)
toe_clearance = df["Toe_clearance"].values
time_vec = df["Time_s"].values
phase_signal = df["Final_Gait_Phase"].values
d_phase = np.diff(phase_signal)
TO_frames = np.where(d_phase == 20)[0] + 1
HS_frames = np.where(d_phase == -20)[0] + 1
print(f"\nTO detected : {len(TO_frames)}")
print(f"HS detected : {len(HS_frames)}")
MIN_SEPARATION = 10
MIN_PROMINENCE = 0.005
mtc_local_idx = 0
missed_no_minima = 0;
results = []
TO_frames = np.where(d_phase == 20)[0] + 1
results = []
missed_no_mtc = 0
missed_negative = 0
    # Process elements in loop
for cycle_idx in range(len(TO_frames) - 1):
    TO = TO_frames[cycle_idx]
    next_TO = TO_frames[cycle_idx + 1]
    signal = toe_clearance[TO:next_TO + 1]
    if len(signal) < 3:
        continue
    global_max_idx = np.argmax(signal)
    if global_max_idx < 2:
        missed_no_mtc += 1
        continue
    mtc_local_idx = None
    # Process elements in loop
    for i in range(global_max_idx - 1, 0, -1):
        if signal[i - 1] > signal[i] and signal[i + 1] > signal[i]:
            mtc_local_idx = i
            break
    if mtc_local_idx is None:
        missed_no_mtc += 1
        continue
    mtc_frame = TO + mtc_local_idx
    mtc_value = toe_clearance[mtc_frame]
    if mtc_value < 0:
        missed_negative += 1
        continue
    mtc_time = time_vec[mtc_frame]
    results.append([
        cycle_idx + 1,
        TO,
        next_TO,
        mtc_frame,
        mtc_time,
        mtc_value
    ])
print("Missed due to no mTC:", missed_no_mtc)
print("Missed due to negative:", missed_negative)
mTC_table = pd.DataFrame(
    results,
    columns=[
        "Cycle",
        "TO_Frame",
        "Next_TO_Frame",
        "mTC_Frame",
        "mTC_Time_s",
        "mTC_Value_m"
    ]
)
print("Missed due to no minima:", missed_no_minima)
total_cycles = len(mTC_table)
if total_cycles > 10:
    mTC_table = mTC_table[(mTC_table["mTC_Time_s"] >=30) & (mTC_table["mTC_Time_s"] <=300)].reset_index(drop=True)
    mTC_table["Cycle"] = np.arange(1,len(mTC_table) + 1)
    hip_angle   = df["Hip_angle"].values
    knee_angle  = df["Knee_angle"].values
    ankle_angle = df["Ankle_angle"].values
    mtc_frames = mTC_table["mTC_Frame"].astype(int).values
    mTC_table["HipAngle_mTC"] = hip_angle[mtc_frames]
    mTC_table["KneeAngle_mTC"] = knee_angle[mtc_frames]
    mTC_table["AnkleAngle_mTC"] = ankle_angle[mtc_frames]
print(f"Length of mTC_table: {len(mTC_table)}")
print(f"\nOriginal cycles : {total_cycles}")
print(f"Remaining cycles   : {len(mTC_table)}")
mtc_values = mTC_table["mTC_Value_m"].values
mean_mtc = np.mean(mtc_values)
std_mtc = np.std(mtc_values)
print("\n==============================")
print("STATISTICS")
print("==============================")
print(f"Mean mTC : {mean_mtc:.4f} m")
print(f"Std  mTC : {std_mtc:.4f} m")
print(f"Min  mTC : {np.min(mtc_values):.4f} m")
print(f"Max  mTC : {np.max(mtc_values):.4f} m")
    # Generate visualizations
plt.figure(figsize=(12,6))
plt.scatter(
    mTC_table["mTC_Time_s"],
    mTC_table["mTC_Value_m"],
    s=70,
    label="mTC"
)
plt.axhline(
    mean_mtc,
    linestyle="--",
    linewidth=2,
    label=f"Mean = {mean_mtc:.4f} m"
)
plt.axhline(
    mean_mtc + std_mtc,
    linestyle=":",
    linewidth=1.5,
    label=f"+1 SD = {mean_mtc + std_mtc:.4f} m"
)
plt.axhline(
    mean_mtc - std_mtc,
    linestyle=":",
    linewidth=1.5,
    label=f"-1 SD = {mean_mtc - std_mtc:.4f} m"
)
plt.xlabel("Time (s)")
plt.ylabel("mTC (m)")
plt.title("Minimum Toe Clearance vs Time")
plt.grid(True)
plt.legend()
plt.tight_layout()
    # Generate visualizations
plt.figure(figsize=(15,6))
plt.plot(
    time_vec,
    toe_clearance,
    linewidth=1.2,
    label="Toe_clearance"
)
plt.scatter(
    mTC_table["mTC_Time_s"],
    mTC_table["mTC_Value_m"],
    s=90,
    label="Detected mTC"
)
plt.xlabel("Time (s)")
plt.ylabel("Toe Clearance (m)")
plt.title("Detected mTC")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
hip_values = mTC_table["HipAngle_mTC"].values
mean_hip = np.mean(hip_values)
std_hip = np.std(hip_values)
print("\nHIP ANGLE @ mTC")
print(f"Mean : {mean_hip:.3f}")
print(f"Std  : {std_hip:.3f}")
    # Generate visualizations
plt.figure(figsize=(12,5))
plt.scatter(
    mTC_table["Cycle"],
    hip_values,
    s=70,
    label="Hip Angle @ mTC"
)
plt.axhline(mean_hip, linestyle="--", linewidth=2,
            label=f"Mean = {mean_hip:.2f}")
plt.axhline(mean_hip + std_hip, linestyle=":", linewidth=1.5,
            label=f"+1 SD = {mean_hip + std_hip:.2f}")
plt.axhline(mean_hip - std_hip, linestyle=":", linewidth=1.5,
            label=f"-1 SD = {mean_hip - std_hip:.2f}")
plt.xlabel("Cycle")
plt.ylabel("Hip Angle (deg)")
plt.title("Hip Angle at mTC")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
knee_values = mTC_table["KneeAngle_mTC"].values
mean_knee = np.mean(knee_values)
std_knee = np.std(knee_values)
print("\nKNEE ANGLE @ mTC")
print(f"Mean : {mean_knee:.3f}")
print(f"Std  : {std_knee:.3f}")
    # Generate visualizations
plt.figure(figsize=(12,5))
plt.scatter(
    mTC_table["Cycle"],
    knee_values,
    s=70,
    label="Knee Angle @ mTC"
)
plt.axhline(mean_knee, linestyle="--", linewidth=2,
            label=f"Mean = {mean_knee:.2f}")
plt.axhline(mean_knee + std_knee, linestyle=":", linewidth=1.5,
            label=f"+1 SD = {mean_knee + std_knee:.2f}")
plt.axhline(mean_knee - std_knee, linestyle=":", linewidth=1.5,
            label=f"-1 SD = {mean_knee - std_knee:.2f}")
plt.xlabel("Cycle")
plt.ylabel("Knee Angle (deg)")
plt.title("Knee Angle at mTC")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
ankle_values = mTC_table["AnkleAngle_mTC"].values
mean_ankle = np.mean(ankle_values)
std_ankle = np.std(ankle_values)
print("\nANKLE ANGLE @ mTC")
print(f"Mean : {mean_ankle:.3f}")
print(f"Std  : {std_ankle:.3f}")
    # Generate visualizations
plt.figure(figsize=(12,5))
plt.scatter(
    mTC_table["Cycle"],
    ankle_values,
    s=70,
    label="Ankle Angle @ mTC"
)
plt.axhline(mean_ankle, linestyle="--", linewidth=2,
            label=f"Mean = {mean_ankle:.2f}")
plt.axhline(mean_ankle + std_ankle, linestyle=":", linewidth=1.5,
            label=f"+1 SD = {mean_ankle + std_ankle:.2f}")
plt.axhline(mean_ankle - std_ankle, linestyle=":", linewidth=1.5,
            label=f"-1 SD = {mean_ankle - std_ankle:.2f}")
plt.xlabel("Cycle")
plt.ylabel("Ankle Angle (deg)")
plt.title("Ankle Angle at mTC")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
print(
    mTC_table[
        [
            "Cycle",
            "mTC_Frame",
            "HipAngle_mTC",
            "KneeAngle_mTC",
            "AnkleAngle_mTC"
        ]
    ].head()
)