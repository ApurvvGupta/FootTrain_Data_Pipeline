% Main script for A2 Right Peak Detection
% Calculates relevant gait features

clc; clear; close all;
kine = readtable("C:\FPA_DP\Ritam_Feedback_CA.xlsx");
cycles = readtable("C:\FPA_DP\Ritam_Feedback_CA_Right_TO_Cycles.xlsx");
Toe_clearance = kine.Toe_clearance;
n_cycles = height(cycles);
peak_table = [];
% Loop through data points
for i = 1:n_cycles
    cycle_id = cycles.Cycle_ID(i);
    st = cycles.TO1_Frame(i);
    en = cycles.TO2_Frame(i);
% Check condition before proceeding
    if isnan(st) || isnan(en) || st < 1 || en > length(Toe_clearance) || en <= st
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
writetable(T_peak, 'Ritam_Feedback_CA_Right_Peak_Detection.xlsx');
fprintf('Saved 