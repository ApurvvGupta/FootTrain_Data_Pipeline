% Main script for A4Right Final Gait Phase
% Calculates relevant gait features

clc; clear; close all;
fprintf('Loading files...\n');
kine = readtable("C:\FPA_DP\Ritam_Feedback_CA.xlsx");
gait = readtable("C:\FPA_DP\Ritam_Feedback_CA_Right_Validated_Gait_Events.xlsx");
n_frames = height(kine);
fprintf('Frames loaded      : 
fprintf('Gait cycles loaded : 
phase_signal_final = zeros(n_frames,1);
STANCE_VAL = 0;
SWING_VAL  = 20;
fprintf('Generating gait phases...\n');
valid_cycles = 0;
invalid_cycles = 0;
% Loop through data points
for i = 1:height(gait)
% Check condition before proceeding
    if gait.Valid(i) == 0
        invalid_cycles = invalid_cycles + 1;
        continue;
    end
    to1 = gait.TO1_Frame(i);
    hs  = gait.HS_Frame(i);
    to2 = gait.TO2_Frame(i);
% Check condition before proceeding
    if isnan(to1) || isnan(hs) || isnan(to2)
        invalid_cycles = invalid_cycles + 1;
        continue;
    end
% Check condition before proceeding
    if to1 < 1 || hs > n_frames || to2 > n_frames
        invalid_cycles = invalid_cycles + 1;
        continue;
    end
% Check condition before proceeding
    if ~(to1 < hs && hs <= to2)
        invalid_cycles = invalid_cycles + 1;
        continue;
    end
    phase_signal_final(to1:hs) = SWING_VAL;
    valid_cycles = valid_cycles + 1;
end
fprintf('Valid cycles used   : 
fprintf('Invalid cycles skip : 
Phase_Table = table(...
    (1:n_frames)', ...
    phase_signal_final, ...
    'VariableNames', { ...
    'Frame_Number', ...
    'Right_Final_Gait_Phase'});
kine.Final_Gait_Phase = phase_signal_final;
writetable(kine,'Ritam_Feedback_CA_Right_Final_Gait_Phase.xlsx');
% Plot the results
figure;
plot(kine.Toe_clearance,'LineWidth',1.5)
hold on
plot(phase_signal_final,'LineWidth',1.5)
xlabel('Frame')
ylabel('Value')
title('Toe Clearance + Final Gait Phase')
legend('Toe Clearance','Gait Phase')
grid on