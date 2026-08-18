% Main script for A5Left Peak detection
% Calculates relevant gait features

clc; clear; close all;
fprintf('Loading files...\n');
kine = readtable("D:\FPA_DP\Saurabh_Baseline.xlsx");
cycles = readtable("D:\FPA_DP\Saurabh_Baseline_Left_TO_Cycles.xlsx");
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
    [peak_val, idx] = max(sig);
    peak_frame = st + idx - 1;
    peak_table(end+1,:) = [cycle_id, peak_frame, peak_val];
end
T_peak = array2table(peak_table, ...
    'VariableNames', { ...
    'Cycle_ID', ...
    'Peak_Frame', ...
    'Peak_Value'});
writetable(T_peak, ...
    'Saurabh_Baseline_Left_Peak_Detection.xlsx');
fprintf('Saved 