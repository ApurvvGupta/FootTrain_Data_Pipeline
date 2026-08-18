# Script dealing with Foot Pitch at Heel Strike
# Processes the dataset and generates outputs

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
file_path = r"C:\FPA_DP\Ritam_Baseline_CA_Right_Final_Gait_Phase.xlsx"
df = pd.read_excel(file_path)
foot_pitch = -df["RightFootY"].values
time_vec = df["Time_s"].values
phase_signal = df["Final_Gait_Phase"].values
d_phase = np.diff(phase_signal)
TO_frames = np.where(d_phase == 20)[0] + 1
HS_frames = np.where(d_phase == -20)[0] + 1
filtered_HS = []
    # Process elements in loop
for frame in HS_frames:
    FPA = foot_pitch[frame]
    if FPA < -30:
        continue
    filtered_HS.append(frame)
HS_frames = np.array(filtered_HS)
print(f"TO detected : {len(TO_frames)}")
print(f"HS detected : {len(HS_frames)}")
hs_pitch = foot_pitch[HS_frames]
hs_time = time_vec[HS_frames]
hs_table = pd.DataFrame({
    "HS_Frame": HS_frames,
    "HS_Time_s": hs_time,
    "Foot_Pitch_at_HS_deg": hs_pitch
})
total_cycles = len(hs_table)
hs_table = hs_table[
    (hs_table["HS_Time_s"] >= 100) &
    (hs_table["HS_Time_s"] <= 300)
].reset_index(drop=True)
hs_table["Cycle"] = np.arange(1, len(hs_table) + 1)
HS_frames = hs_table["HS_Frame"].values
hs_time = hs_table["HS_Time_s"].values
hs_pitch = hs_table["Foot_Pitch_at_HS_deg"].values
print(f"Length of hs_table: {len(hs_table)}")
print(f"\nOriginal cycles : {total_cycles}")
print(f"Remaining cycles   : {len(hs_table)}")
mean_pitch = np.mean(hs_pitch)
std_pitch = np.std(hs_pitch)
print("\n==============================")
print("FOOT PITCH AT HEEL STRIKE")
print("==============================")
print(f"Mean : {mean_pitch:.2f} deg")
print(f"Std  : {std_pitch:.2f} deg")
print(f"Min  : {np.min(hs_pitch):.2f} deg")
print(f"Max  : {np.max(hs_pitch):.2f} deg")
    # Generate visualizations
plt.figure(figsize=(12, 6))
plt.scatter(
    hs_time,
    hs_pitch,
    s=70,
    label="Foot Pitch at Heel Strike"
)
plt.axhline(
    mean_pitch,
    linestyle="--",
    linewidth=2,
    label=f"Mean = {mean_pitch:.2f}°"
)
plt.axhline(
    mean_pitch + std_pitch,
    linestyle=":",
    linewidth=1.5,
    label=f"+1 SD = {mean_pitch + std_pitch:.2f}°"
)
plt.axhline(
    mean_pitch - std_pitch,
    linestyle=":",
    linewidth=1.5,
    label=f"-1 SD = {mean_pitch - std_pitch:.2f}°"
)
plt.xlabel("Time (s)")
plt.ylabel("Foot Pitch at Heel Strike (deg)")
plt.title("Foot Pitch at Heel Strike")
plt.grid(True)
plt.legend()
plt.tight_layout()
    # Generate visualizations
plt.figure(figsize=(15, 6))
plt.plot(
    time_vec,
    foot_pitch,
    linewidth=1,
    label="Right Foot Pitch"
)
plt.scatter(
    time_vec[HS_frames],
    foot_pitch[HS_frames],
    color="red",
    s=30,
    label="Heel Strike"
)
plt.xlabel("Time (s)")
plt.ylabel("Foot Pitch (deg)")
plt.title("Heel Strike Verification")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()