# Script dealing with p-test
# Processes the dataset and generates outputs

import numpy as np
import pandas as pd
from scipy.stats import ttest_rel, wilcoxon, shapiro
subjects = [
    "Apurv",
    "Arijit",
    "Ravindra",
    "Saurabh",
    "Snehasis",
    "Varun"
]
data = {
    "FPA_baseline":      [21.24, 17.76, 17.92, 18.35, 21.64, 10.40],
    "FPA_feedback":      [23.76, 25.71, 25.65, 25.80, 29.92, 19.16],
    "mTC_baseline":      [17, 6.1, 5, 9.5, 12.9, 26.9],
    "mTC_feedback":      [27.7, 10.8, 9.6, 15.6, 16.7, 41.9],
    "Hip_baseline":      [36.03, 24.52, 21.86, 26.13, 26.34, 26.74],
    "Hip_feedback":      [32.95, 25.58, 16.91, 22.20, 23.76, 27.80],
    "Knee_baseline":     [45.31, 40.45, 42.95, 49.80, 48.88, 48.61],
    "Knee_feedback":     [45.54, 43.71, 42.18, 53.87, 51.24, 51.81],
    "Ankle_baseline":    [-0.18, -1.14, -5.00, -6.90, -5.90, -1.19],
    "Ankle_feedback":    [-0.77, 1.65, -2.01, -4.83, 0.20, 2.57],
    "StepLength_baseline": [50.6, 51.3, 56.7, 53.5, 50.3, 49.8],
    "StepLength_feedback": [56.9, 57.4, 59.1, 52.9, 52.8, 58.0]
}
df = pd.DataFrame(data, index=subjects)
print("========= DATA =========")
print(df)
print()
    # Initialize function with given parameters
def paired_test(parameter):
    baseline = df[f"{parameter}_baseline"]
    feedback = df[f"{parameter}_feedback"]
    diff = feedback - baseline
    sh_stat, sh_p = shapiro(diff)
    t_stat, t_p = ttest_rel(feedback, baseline)
    try:
        w_stat, w_p = wilcoxon(feedback, baseline)
    except:
        w_stat, w_p = np.nan, np.nan
    print("=" * 70)
    print(f"Parameter: {parameter}")
    print("-" * 70)
    print(f"Baseline Mean : {baseline.mean():.4f}")
    print(f"Feedback Mean : {feedback.mean():.4f}")
    print(f"Mean Change   : {diff.mean():.4f}")
    print()
    print("Shapiro-Wilk Test (Normality of paired differences):")
    print(f"Statistic = {sh_stat:.4f}")
    print(f"p-value   = {sh_p:.6f}")
    if sh_p > 0.05:
        print("Result    = Differences are approximately NORMAL")
        recommended = "Paired t-test"
    else:
        print("Result    = Differences are NOT normal")
        recommended = "Wilcoxon Signed Rank"
    print()
    print("Paired t-test:")
    print(f"t-statistic = {t_stat:.4f}")
    print(f"p-value     = {t_p:.6f}")
    if t_p < 0.05:
        print("Result      = Significant (p < 0.05)")
    else:
        print("Result      = Not Significant")
    print()
    print("Wilcoxon Signed Rank:")
    print(f"Statistic   = {w_stat}")
    print(f"p-value     = {w_p}")
    if not np.isnan(w_p):
        if w_p < 0.05:
            print("Result      = Significant (p < 0.05)")
        else:
            print("Result      = Not Significant")
    print()
    print(f"Recommended Test to Trust More: {recommended}")
    if len(subjects) < 10:
        print("NOTE: Sample size is very small (n=6), so Wilcoxon is generally safer.")
    print("=" * 70)
    print()
parameters = ["FPA", "mTC", "Hip", "Knee", "Ankle", "StepLength"]
    # Process elements in loop
for param in parameters:
    paired_test(param)