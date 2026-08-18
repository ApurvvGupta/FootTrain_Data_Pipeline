% Main script for A3 Right Validated Gait Events
% Calculates relevant gait features

clc; clear; close all;
cycles = readtable("C:\FPA_DP\Ritam_Feedback_CA_Right_TO_Cycles.xlsx");
peaks  = readtable("C:\FPA_DP\Ritam_Feedback_CA_Right_Peak_Detection.xlsx");
hs_tbl = readtable("C:\FPA_DP\Ritam_Feedback_CA_Right_Detected_HS.xlsx");
HS_all = hs_tbl.HS_Frame;
merge_table = [];
% Loop through data points
for i = 1:height(cycles)
    cycle_id = cycles.Cycle_ID(i);
    to1 = cycles.TO1_Frame(i);
    to2 = cycles.TO2_Frame(i);
    peak = peaks.Peak_Frame(i);
    hs_final = peak + 2;
% Check condition before proceeding
    if hs_final > to2
        valid = 0;
    else
        valid = 1;
    end
    merge_table = [merge_table;
        cycle_id, to1, to2, peak, hs_final, valid];
end
T_final = array2table(merge_table, ...
    'VariableNames', { ...
    'Cycle_ID', ...
    'TO1_Frame', ...
    'TO2_Frame', ...
    'Peak_Frame', ...
    'HS_Frame', ...
    'Valid'});
writetable(T_final,'Ritam_Feedback_CA_Right_Validated_Gait_Events.xlsx');
fprintf('Total cycles : 
fprintf('Valid cycles : 
fprintf('Invalid      : 