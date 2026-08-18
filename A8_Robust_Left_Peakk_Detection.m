% Main script for A8 Robust Left Peakk Detection
% Calculates relevant gait features

clc; clear; close all;
fprintf('Loading files...\n');
kine = readtable("C:\FPA_DP\Ritam_Feedback_CA.xlsx");
cycles = readtable("C:\FPA_DP\Ritam_Feedback_CA_Left_TO_Cycles.xlsx");
Toe_clearance = kine.Left_Toe_clearance;
n_cycles = height(cycles);
fprintf('Frames loaded : 
fprintf('Cycles loaded : 
peak_table = [];
% Loop through data points
for i = 1:n_cycles
    cycle_id = cycles.Cycle_ID(i);
    st = cycles.TO1_Frame(i);
    en = cycles.TO2_Frame(i);
% Check condition before proceeding
    if isnan(st) || isnan(en)
        peak_table(end+1,:) = [cycle_id, NaN, NaN];
        continue;
    end
% Check condition before proceeding
    if st < 1 || en > length(Toe_clearance)
        peak_table(end+1,:) = [cycle_id, NaN, NaN];
        continue;
    end
% Check condition before proceeding
    if en <= st
        peak_table(end+1,:) = [cycle_id, NaN, NaN];
        continue;
    end
    sig = Toe_clearance(st:en);
    cycle_len = length(sig);
    start_idx = max(1, round(0.15 * cycle_len));
    search_sig = sig(start_idx:end);
    [pks, locs] = findpeaks(search_sig, ...
        'MinPeakProminence', 0.005, ...
        'MinPeakDistance', 10);
% Check condition before proceeding
    if isempty(pks)
        peak_table(end+1,:) = [cycle_id, NaN, NaN];
        continue;
    end
    peak_val = pks(1);
    idx = locs(1) + start_idx - 1;
    peak_frame = st + idx - 1;
    peak_table(end+1,:) = [cycle_id, peak_frame, peak_val];
end
T_peak = array2table(peak_table, ...
    'VariableNames', { ...
    'Cycle_ID', ...
    'Peak_Frame', ...
    'Peak_Value'});
writetable(T_peak, ...
    'Ritam_Feedback_CA_Left_Peak_Detection.xlsx');
fprintf('Saved 