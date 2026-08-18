% Main script for A1 GAIT EVENT Detection
% Calculates relevant gait features

clc; clear; close all;
mvnx_file  = "C:\Users\ariji\Desktop\@SAURABH\SUB_07_TANBHAV\XSENS_IMU_DATA\MAHIR-002#MAHIR.mvnx";
KINEMATICS_CSV = 'sAURABH_MAHIR_CA.xlsx';
GT_label   = 'pRightGreaterTrochanter';
M5_label   = 'pRightFifthMetatarsal';
Heel_label = 'pRightHeelFoot';
LM5_label  = 'pLeftFifthMetatarsal';   
LHeel_label = 'pLeftHeelFoot';         
HIP_JOINT_LABEL   = 'Right Hip';
KNEE_JOINT_LABEL  = 'Right Knee';
ANKLE_JOINT_LABEL = 'Right Ankle';
FLEX_EXT_COMP     = 3;   
VERT_AXIS = 3;   
AP_AXIS   = 1;   
ML_AXIS   = 2;   
ax_names  = {'X','Y','Z'};
AP_THRESH_M       = 0.001;   
SMOOTH_WIN_S      = 0.05;    
MIN_SWING_DUR_FR  = 20;      
MIN_SWING_GAP_FR  = 4;       
RIGHT_PHASE_ZERO_AFTER_TO_FR = 0;   
LEFT_PHASE_ZERO_AFTER_TO_FR = 0;
MIN_STRIDE_S = 0.60;   
MAX_STRIDE_S = 2.50;   
STANCE_FRAC_MIN = 0.35;
STANCE_FRAC_MAX = 0.80;
VEL_THRESH      = 0.10;   
MIN_BOUT_S      = 2.0;    
STANCE_VAL   =  0;    
SWING_VAL    = 20;    
STANCE_LEVEL = 25;    
SWING_LEVEL  = -25;   
% Check condition before proceeding
if ~isfile(mvnx_file), error('File not found: 
tree           = xmlread(char(mvnx_file));
subject_node   = tree.getElementsByTagName('subject').item(0);
frames_node    = tree.getElementsByTagName('frames').item(0);
frame_list     = frames_node.getElementsByTagName('frame');
n_frames_total = frame_list.getLength;
frame_rate = 100;
try
    fr = str2double(char(subject_node.getAttribute('frameRate')));
% Check condition before proceeding
    if ~isnan(fr) && fr > 0, frame_rate = fr; end
catch
end
fprintf('Frames: 
fprintf('STEP 2: Segment definitions...\n');
seg_parent    = tree.getElementsByTagName('segments').item(0);
% Check condition before proceeding
if isempty(seg_parent), error('No <segments> block.'); end
segment_nodes = seg_parent.getElementsByTagName('segment');
n_segments    = segment_nodes.getLength;
segment_names = cell(n_segments,1);
GT_seg_idx=[]; GT_local=[];
M5_seg_idx=[]; M5_local=[];
Heel_seg_idx=[]; Heel_local=[];
LM5_seg_idx=[]; LM5_local=[];
LHeel_seg_idx=[]; LHeel_local=[];
RightFoot_seg_idx = [];
RightToe_seg_idx  = [];
% Loop through data points
for s = 0:n_segments-1
    seg = segment_nodes.item(s);
    nm  = getAttrFallback(seg, {'label','name','id'});
    segment_names{s+1} = nm;
    pt_nodes = seg.getElementsByTagName('point');
% Loop through data points
    for p = 0:pt_nodes.getLength-1
        pt  = pt_nodes.item(p);
        lbl = getAttrFallback(pt, {'label','name','id'});
        loc = readLocalXYZ(pt);
% Check condition before proceeding
        if     strcmpi(lbl,GT_label),   GT_seg_idx=s+1; GT_local=loc;
        elseif strcmpi(lbl,M5_label),   M5_seg_idx=s+1; M5_local=loc;
        elseif strcmpi(lbl,Heel_label), Heel_seg_idx=s+1; Heel_local=loc;
        elseif strcmpi(lbl,LM5_label),   LM5_seg_idx=s+1; LM5_local=loc;
        elseif strcmpi(lbl,LHeel_label), LHeel_seg_idx=s+1; LHeel_local=loc;
        elseif strcmpi(nm,'RightFoot'), RightFoot_seg_idx = s+1;
        elseif strcmpi(nm,'RightToe'), RightToe_seg_idx = s+1;
        end
    end
end
% Check condition before proceeding
if isempty(GT_seg_idx),   error('GT not found.');   end
% Check condition before proceeding
if isempty(M5_seg_idx),   error('M5 not found.');   end
% Check condition before proceeding
if isempty(Heel_seg_idx), error('Heel not found.'); end
% Check condition before proceeding
if isempty(LM5_seg_idx),  error('Left M5 not found.'); end
% Check condition before proceeding
if isempty(LHeel_seg_idx), error('Left Heel not found.'); end
fprintf('  GT   → seg 
fprintf('  M5   → seg 
fprintf('  Heel → seg 
fprintf('  LM5  → seg 
fprintf('  LHeel→ seg 
fprintf('STEP 3: Joint definitions...\n');
joints_parent   = tree.getElementsByTagName('joints').item(0);
hip_joint_idx=-1; knee_joint_idx=-1; ankle_joint_idx=-1;
n_joints=0; all_joint_labels={};
% Check condition before proceeding
if ~isempty(joints_parent)
    joint_nodes = joints_parent.getElementsByTagName('joint');
    n_joints    = joint_nodes.getLength;
% Loop through data points
    for j=0:n_joints-1
        all_joint_labels{end+1} = getAttrFallback(joint_nodes.item(j),{'label','name','id'}); 
    end
% Loop through data points
    for j=0:n_joints-1
        lbl=all_joint_labels{j+1};
% Check condition before proceeding
        if strcmpi(lbl,HIP_JOINT_LABEL),   hip_joint_idx=j;   end
% Check condition before proceeding
        if strcmpi(lbl,KNEE_JOINT_LABEL),  knee_joint_idx=j;  end
% Check condition before proceeding
        if strcmpi(lbl,ANKLE_JOINT_LABEL), ankle_joint_idx=j; end
    end
% Loop through data points
    for j=0:n_joints-1
        ll=lower(all_joint_labels{j+1});
% Check condition before proceeding
        if hip_joint_idx<0   && contains(ll,'right') && contains(ll,'hip'),   hip_joint_idx=j;   end
% Check condition before proceeding
        if knee_joint_idx<0  && contains(ll,'right') && contains(ll,'knee'),  knee_joint_idx=j;  end
% Check condition before proceeding
        if ankle_joint_idx<0 && contains(ll,'right') && contains(ll,'ankle'), ankle_joint_idx=j; end
    end
% Check condition before proceeding
    if hip_joint_idx  >=0, fprintf('  Hip   → joint 
% Check condition before proceeding
    if knee_joint_idx >=0, fprintf('  Knee  → joint 
% Check condition before proceeding
    if ankle_joint_idx>=0, fprintf('  Ankle → joint 
% Check condition before proceeding
    if hip_joint_idx<0 || knee_joint_idx<0 || ankle_joint_idx<0
        fprintf('\n   Some joints not found. All joints:\n');
% Loop through data points
        for j=0:n_joints-1, fprintf('    [
    end
end
has_hip=(hip_joint_idx>=0); has_knee=(knee_joint_idx>=0); has_ankle=(ankle_joint_idx>=0);
fprintf('\n');
fprintf('STEP 4: Extracting frame data...\n');
time_vec        = nan(n_frames_total,1);
GT_pos_all      = nan(n_frames_total,3);
M5_pos_all      = nan(n_frames_total,3);
Heel_pos_all    = nan(n_frames_total,3);
LM5_pos_all     = nan(n_frames_total,3);
LHeel_pos_all   = nan(n_frames_total,3);
hip_angle_all   = nan(n_frames_total,1);
knee_angle_all  = nan(n_frames_total,1);
ankle_angle_all = nan(n_frames_total,1);
RightFoot_vel_all = nan(n_frames_total,3);
RightToe_vel_all  = nan(n_frames_total,3);
valid_f         = false(n_frames_total,1);
% Loop through data points
for f = 0:n_frames_total-1
    frame = frame_list.item(f);
% Check condition before proceeding
    if ~strcmpi(strtrim(char(frame.getAttribute('type'))),'normal'), continue; end
    t_ms = str2double(char(frame.getAttribute('time')));
    time_vec(f+1) = ternary(isnan(t_ms), f/frame_rate, t_ms/1000);
    pos_el = frame.getElementsByTagName('position').item(0);
    ori_el = frame.getElementsByTagName('orientation').item(0);
% Check condition before proceeding
    if isempty(pos_el) || isempty(ori_el)
        continue;
    end
    pv = sscanf(char(pos_el.getTextContent),'
    ov = sscanf(char(ori_el.getTextContent),'
% Check condition before proceeding
    if numel(pv)<3*n_segments||numel(ov)<4*n_segments, continue; end
    sp = reshape(pv(1:3*n_segments),3,n_segments)';
    sq = reshape(ov(1:4*n_segments),4,n_segments)';
    GT_pos_all(f+1,:)   = sp(GT_seg_idx,:)   + quatRot(sq(GT_seg_idx,:),   GT_local);
    M5_pos_all(f+1,:)   = sp(M5_seg_idx,:)   + quatRot(sq(M5_seg_idx,:),   M5_local);
    Heel_pos_all(f+1,:) = sp(Heel_seg_idx,:) + quatRot(sq(Heel_seg_idx,:), Heel_local);
    LM5_pos_all(f+1,:)  = sp(LM5_seg_idx,:)  + quatRot(sq(LM5_seg_idx,:),  LM5_local);
    LHeel_pos_all(f+1,:) = sp(LHeel_seg_idx,:) + quatRot(sq(LHeel_seg_idx,:), LHeel_local);
    ja_el = frame.getElementsByTagName('jointAngle').item(0);
% Check condition before proceeding
    if ~isempty(ja_el) && n_joints>0
        jav = sscanf(char(ja_el.getTextContent),'
% Check condition before proceeding
        if has_hip   && (hip_joint_idx  *3+FLEX_EXT_COMP)<=numel(jav), hip_angle_all(f+1)  =jav(hip_joint_idx  *3+FLEX_EXT_COMP); end
% Check condition before proceeding
        if has_knee  && (knee_joint_idx *3+FLEX_EXT_COMP)<=numel(jav), knee_angle_all(f+1) =jav(knee_joint_idx *3+FLEX_EXT_COMP); end
% Check condition before proceeding
        if has_ankle && (ankle_joint_idx*3+FLEX_EXT_COMP)<=numel(jav), ankle_angle_all(f+1)=jav(ankle_joint_idx*3+FLEX_EXT_COMP); end
    end
    valid_f(f+1) = true;
% Check condition before proceeding
    if mod(f,500)==0, fprintf('  Frame 
end
vr           = valid_f & all(~isnan(GT_pos_all),2) & all(~isnan(M5_pos_all),2);
GT_pos       = GT_pos_all(vr,:);
M5_pos       = M5_pos_all(vr,:);
Heel_pos     = Heel_pos_all(vr,:);
LM5_pos      = LM5_pos_all(vr,:);
LHeel_pos    = LHeel_pos_all(vr,:);
hip_angle    = hip_angle_all(vr);
knee_angle   = knee_angle_all(vr);
ankle_angle  = ankle_angle_all(vr);
time_vec     = time_vec(vr);
n_frames     = size(GT_pos,1);
fprintf('  Valid frames: 
% Check condition before proceeding
if n_frames==0, error('No valid frames.'); end
fprintf('STEP 5: Axis verification...\n');
vd = mean(GT_pos(:,VERT_AXIS)) - mean(M5_pos(:,VERT_AXIS));
fprintf('  GT-M5 vertical (
% Check condition before proceeding
if vd < 0
    fprintf(' → inverting 
    GT_pos(:,VERT_AXIS)   = -GT_pos(:,VERT_AXIS);
    M5_pos(:,VERT_AXIS)   = -M5_pos(:,VERT_AXIS);
    Heel_pos(:,VERT_AXIS) = -Heel_pos(:,VERT_AXIS);
    LM5_pos(:,VERT_AXIS)   = -LM5_pos(:,VERT_AXIS);
    LHeel_pos(:,VERT_AXIS) = -LHeel_pos(:,VERT_AXIS);
else
    fprintf(' \n');
end
M5_Z_raw = M5_pos(:,VERT_AXIS);
LM5_Z_raw = LM5_pos(:,VERT_AXIS);
fprintf('\n');
fprintf('STEP 6: Phase signal from M5 AP velocity...\n');
fprintf('  Threshold: 
        AP_THRESH_M, AP_THRESH_M*frame_rate, frame_rate);
sm_win  = max(3, round(frame_rate * SMOOTH_WIN_S));
M5_X    = M5_pos(:, AP_AXIS);           
M5_X_sm = smoothdata(M5_X, 'gaussian', sm_win);   
ap_disp        = abs(diff(M5_X_sm));     
ap_disp        = [ap_disp(1); ap_disp]; 
binary = double(ap_disp >= AP_THRESH_M);   
binary = medfilt1(binary, 3);
binary = double(binary >= 0.5);       
binary = fillShortGaps(binary, 1, MIN_SWING_GAP_FR);
binary = removeShortBursts(binary, 1, MIN_SWING_DUR_FR);
phase_signal = binary * 20;   
n_swing_frames  = sum(phase_signal == 20);
n_stance_frames = sum(phase_signal == 0);
fprintf('  Stance frames: 
fprintf('  Swing  frames: 
fprintf('STEP 7: Event detection from phase edges...\n');
d_phase = diff(phase_signal);
TO_frames = find(d_phase == +20) + 1;
fprintf('STEP 7.5: Saving TO-to-TO cycles...\n');
TO_cycle_table = [];
% Loop through data points
for i = 1:length(TO_frames)-1
    to1 = TO_frames(i);
    to2 = TO_frames(i+1);
% Check condition before proceeding
    if isnan(to1) || isnan(to2)
        continue;
    end
% Check condition before proceeding
    if to2 <= to1
        continue;
    end
    t1 = time_vec(to1);
    t2 = time_vec(to2);
    dur = t2 - t1;
    TO_cycle_table(end+1,:) = [i, to1, to2, t1, t2, dur];
end
fprintf('Saved 
HS_frames = find(d_phase == -20) + 1;
HS_table = [];
% Loop through data points
for i = 1:length(HS_frames)
    hs = HS_frames(i);
    hs_time = time_vec(hs);
    HS_table(end+1,:) = [i, hs, hs_time];
end
fprintf('Raw HS saved in memory: 
fprintf('  Toe-offs     (rising  edges 0→20): 
fprintf('  Heel-strikes (falling edges 20→0): 
fprintf('STEP 8: Direction detection...\n');
dt       = mean(diff(time_vec));
GT_vel   = gradient(GT_pos(:,AP_AXIS), dt);   
med_win  = max(3, round(1.0 / dt));
vel_sm   = medfilt1(GT_vel, med_win);
dir_label = zeros(n_frames,1);
dir_label(vel_sm >  VEL_THRESH) =  1;
dir_label(vel_sm < -VEL_THRESH) = -1;
MIN_BOUT_FRAMES = round(MIN_BOUT_S / dt);
bouts = identifyBouts(dir_label, MIN_BOUT_FRAMES);
% Loop through data points
for b = 1:size(bouts,1)
    dir_names = {'Backward','Transition','Forward'};
    fprintf('  Bout 
            b, dir_names{bouts(b,3)+2}, ...
            bouts(b,1), bouts(b,2), ...
            time_vec(bouts(b,1)), time_vec(bouts(b,2)));
end
fprintf('\n');
fprintf('STEP 9: Stride pairing...\n');
stride_table = [];
% Loop through data points
for h = 1:numel(HS_frames)
    hs1    = HS_frames(h);
    nxt_TO = TO_frames(TO_frames > hs1);
% Check condition before proceeding
    if isempty(nxt_TO), continue; end
    to     = nxt_TO(1);
    nxt_HS = HS_frames(HS_frames > to);
% Check condition before proceeding
    if isempty(nxt_HS), continue; end
    hs2    = nxt_HS(1);
    stride_dur  = time_vec(hs2) - time_vec(hs1);
    stance_dur  = time_vec(to)  - time_vec(hs1);
    stance_frac = stance_dur / stride_dur;
% Check condition before proceeding
    if stride_dur  < MIN_STRIDE_S    || stride_dur  > MAX_STRIDE_S,    continue; end
% Check condition before proceeding
    if stance_frac < STANCE_FRAC_MIN || stance_frac > STANCE_FRAC_MAX, continue; end
    mid_f     = min(round((hs1+hs2)/2), n_frames);
    stride_dir= dir_label(mid_f);
    stride_table(end+1,:) = [hs1, to, hs2, stride_dir, stride_dur, stance_frac]; 
end
n_strides = size(stride_table,1);
n_fwd     = sum(stride_table(:,4) ==  1);
n_bwd     = sum(stride_table(:,4) == -1);
n_trans   = sum(stride_table(:,4) ==  0);
fprintf('  Valid strides: 
        n_strides, n_fwd, n_bwd, n_trans);
fprintf('STEP 10: TLA...\n');
V          = M5_pos - GT_pos;
V_AP_col = V(:, AP_AXIS);   
TLA_deg    = rad2deg(atan2(abs(V(:,AP_AXIS)), abs(V(:,VERT_AXIS))));
TLA_signed = TLA_deg .* (-sign(V(:,AP_AXIS)));
fprintf('  TLA range: 
fprintf('STEP 11: Peak TLA per stride...\n');
search_win   = round(frame_rate * 0.35);
peak_TLA_fwd = []; peak_frames_fwd = [];
peak_TLA_bwd = []; peak_frames_bwd = [];
% Loop through data points
for i = 1:n_strides
    to    = stride_table(i,2);
    dir_i = stride_table(i,4);
    sf    = max(1, to - search_win);
    win   = TLA_signed(sf:to);
    [pv, pi_] = max(win);
    pf    = sf + pi_ - 1;
% Check condition before proceeding
    if ~isnan(pv) && pv >= 3 && pv <= 45
% Check condition before proceeding
        if dir_i ==  1, peak_TLA_fwd(end+1)=pv; peak_frames_fwd(end+1)=pf; end
% Check condition before proceeding
        if dir_i == -1, peak_TLA_bwd(end+1)=pv; peak_frames_bwd(end+1)=pf; end
    end
end
peak_TLA_fwd = removeOutliers(peak_TLA_fwd);
peak_TLA_bwd = removeOutliers(peak_TLA_bwd);
mean_TLA_fwd = safeStats(peak_TLA_fwd,'mean'); std_TLA_fwd = safeStats(peak_TLA_fwd,'std');
mean_TLA_bwd = safeStats(peak_TLA_bwd,'mean'); std_TLA_bwd = safeStats(peak_TLA_bwd,'std');
fprintf('  Fwd TLA: 
fprintf('  Bwd TLA: 
Right_Phase_signal = phase_signal;  
% Loop through data points
for k = 1:numel(TO_frames)
    st = TO_frames(k);
    en = min(st + RIGHT_PHASE_ZERO_AFTER_TO_FR - 1, n_frames);
    Right_Phase_signal(st:en) = 0;
end
fprintf('  Right phase correction: first 
LM5_X    = LM5_pos(:, AP_AXIS);
LM5_X_sm = smoothdata(LM5_X, 'gaussian', sm_win);
left_ap_disp = abs(diff(LM5_X_sm));
left_ap_disp = [left_ap_disp(1); left_ap_disp];
left_binary = double(left_ap_disp >= AP_THRESH_M);
left_binary = medfilt1(left_binary, 3);
left_binary = double(left_binary >= 0.5);
left_binary = fillShortGaps(left_binary, 1, MIN_SWING_GAP_FR);
left_binary = removeShortBursts(left_binary, 1, MIN_SWING_DUR_FR);
Left_Phase_signal = left_binary * 20;
left_d_phase = diff(Left_Phase_signal);
L_TO_frames = find(left_d_phase == -20) + 1;
L_HS_frames = find(left_d_phase == +20) + 1;
Left_Final_Phase_signal = Left_Phase_signal;
% Loop through data points
for k = 1:numel(L_TO_frames)
    st = L_TO_frames(k);
    en = min(st + LEFT_PHASE_ZERO_AFTER_TO_FR - 1, n_frames);
    Left_Final_Phase_signal(st:en) = 0;
end
n_left_swing  = sum(Left_Final_Phase_signal == 20);
n_left_stance = sum(Left_Final_Phase_signal == 0);
fprintf('  Left stance frames: 
    n_left_stance, 100*n_left_stance/n_frames);
fprintf('  Left swing frames: 
    n_left_swing, 100*n_left_swing/n_frames);
RHeel_AP = Heel_pos(:, AP_AXIS);
LHeel_AP = LHeel_pos(:, AP_AXIS);
fprintf('STEP 14: Saving kinematics CSV...\n');
dir_per_frame = dir_label;   
T_kine = table(...
    (1:n_frames)',   time_vec, ...
    hip_angle,       knee_angle,      ankle_angle, ...
    M5_Z_raw,        LM5_Z_raw,       M5_X, ...
    ap_disp,         phase_signal, ...
    Right_Phase_signal, ...
    dir_per_frame,   TLA_signed, ...
    TLA_deg,         V_AP_col, ...
    RHeel_AP,        LHeel_AP,        Left_Final_Phase_signal, ...
    'VariableNames', { ...
        'Frame_number', 'Time_s', ...
        'Hip_angle', 'Knee_angle', 'Ankle_angle', ...
        'Toe_clearance', 'Left_Toe_clearance', 'M5_X_m', ...
        'M5_AP_disp_m_per_frame', 'Phase_signal', ...
        'Right_Phase_signal', ...
        'Walking_direction', 'TLA', 'TLA_deg', 'V_AP', ...
        'RHeel_AP', 'LHeel_AP', 'Left_Final_Phase_signal'});
writetable(T_kine, KINEMATICS_CSV);
fprintf('  
T_TO_cycles = array2table(TO_cycle_table, ...
    'VariableNames', { ...
    'Cycle_ID', ...
    'TO1_Frame', ...
    'TO2_Frame', ...
    'TO1_Time_s', ...
    'TO2_Time_s', ...
    'Duration_s'});
writetable(T_TO_cycles, 'Ritam_Feedback_CA_Right_TO_Cycles.xlsx');
T_HS = array2table(HS_table, ...
    'VariableNames', { ...
    'HS_ID', ...
    'HS_Frame', ...
    'HS_Time_s'});
writetable(T_HS, 'Ritam_Feedback_CA_Right_Detected_HS.xlsx');
Left_TO_cycle_table = [];
% Loop through data points
for i = 1:length(L_TO_frames)-1
    to1 = L_TO_frames(i);
    to2 = L_TO_frames(i+1);
% Check condition before proceeding
    if isnan(to1) || isnan(to2)
        continue;
    end
% Check condition before proceeding
    if to2 <= to1
        continue;
    end
    t1 = time_vec(to1);
    t2 = time_vec(to2);
    dur = t2 - t1;
    Left_TO_cycle_table(end+1,:) = [i, to1, to2, t1, t2, dur];
end
T_Left_TO_cycles = array2table(Left_TO_cycle_table, ...
    'VariableNames', { ...
    'Cycle_ID', ...
    'TO1_Frame', ...
    'TO2_Frame', ...
    'TO1_Time_s', ...
    'TO2_Time_s', ...
    'Duration_s'});
writetable(T_Left_TO_cycles, ...
    'Ritam_Feedback_CA_Left_TO_Cycles.xlsx');
Left_HS_table = [];
% Loop through data points
for i = 1:length(L_HS_frames)
    hs = L_HS_frames(i);
    hs_time = time_vec(hs);
    Left_HS_table(end+1,:) = [i, hs, hs_time];
end
T_Left_HS = array2table(Left_HS_table, ...
    'VariableNames', { ...
    'HS_ID', ...
    'HS_Frame', ...
    'HS_Time_s'});
writetable(T_Left_HS, ...
    'Ritam_Feedback_CA_Left_Detected_HS.xlsx');
fprintf('STEP 15: Saving MAT...\n');
gait_events.TO_frames = TO_frames;
gait_events.HS_frames = HS_frames;
gait_events.TO_times_sec = time_vec(TO_frames);
gait_events.HS_times_sec = time_vec(HS_frames);
gait_events.L_TO_frames = L_TO_frames;
gait_events.L_HS_frames = L_HS_frames;
gait_events.L_TO_times_sec = time_vec(L_TO_frames);
gait_events.L_HS_times_sec = time_vec(L_HS_frames);
gait_events.stride_table = stride_table;
gait_events.phase_signal = phase_signal;
gait_events.Right_Phase_signal = Right_Phase_signal;
gait_events.Left_Phase_signal = Left_Phase_signal;
gait_events.Left_Final_Phase_signal = Left_Final_Phase_signal;
gait_events.dir_label = dir_label;
gait_events.M5_X_sm = M5_X_sm;
gait_events.ap_disp = ap_disp;
gait_events.RHeel_AP = RHeel_AP;
gait_events.LHeel_AP = LHeel_AP;
gait_events.time_vec = time_vec;
gait_events.phase_method = 'M5 AP velocity threshold';
gait_events.AP_THRESH_M = AP_THRESH_M;
gait_events.RIGHT_PHASE_ZERO_AFTER_TO_FR = RIGHT_PHASE_ZERO_AFTER_TO_FR;
gait_events.LEFT_PHASE_ZERO_AFTER_TO_FR = LEFT_PHASE_ZERO_AFTER_TO_FR;
fprintf('\nAll done.\n');
% Define main function and return values
function out = fillShortGaps(x, val, max_gap)
    out = x;
    n   = numel(x);
    i   = 1;
% Loop through data points
    while i <= n
% Check condition before proceeding
        if x(i) ~= val
            j = i;
% Loop through data points
            while j <= n && x(j) ~= val, j=j+1; end
            gap_len = j - i;
% Check condition before proceeding
            if gap_len <= max_gap
                out(i:j-1) = val;   
            end
            i = j;
        else
            i = i + 1;
        end
    end
end
% Define main function and return values
function out = removeShortBursts(x, val, min_dur)
    out = x;
    n   = numel(x);
    i   = 1;
% Loop through data points
    while i <= n
% Check condition before proceeding
        if x(i) == val
            j = i;
% Loop through data points
            while j <= n && x(j) == val, j=j+1; end
            burst_len = j - i;
% Check condition before proceeding
            if burst_len < min_dur
                out(i:j-1) = 1 - val;   
            end
            i = j;
        else
            i = i + 1;
        end
    end
end
% Define main function and return values
function bouts = identifyBouts(dir_label, min_frames)
    bouts=[]; n=numel(dir_label); i=1;
% Loop through data points
    while i<=n
        j=i;
% Loop through data points
        while j<=n && dir_label(j)==dir_label(i), j=j+1; end
% Check condition before proceeding
        if (j-i)>=min_frames, bouts(end+1,:)=[i,j-1,dir_label(i)]; end 
        i=j;
    end
% Check condition before proceeding
    if isempty(bouts), bouts=zeros(0,3); end
end
% Define main function and return values
function out = removeOutliers(v)
% Check condition before proceeding
    if numel(v)<3, out=v; return; end
    mu=mean(v,'omitnan'); sg=std(v,'omitnan');
% Check condition before proceeding
    if sg==0, out=v; return; end
    out=v(abs(v-mu)<=2*sg);
end
% Define main function and return values
function v = safeStats(vals,stat)
% Check condition before proceeding
    if isempty(vals), v=NaN; return; end
% Check condition before proceeding
    if strcmp(stat,'mean'), v=mean(vals,'omitnan'); else, v=std(vals,'omitnan'); end
end
% Define main function and return values
function shadeDirectionZones(ax, t, dl, min_s, cf, cb)
    dt=mean(diff(t)); mf=round(min_s/dt);
% Loop through data points
    for val=[1,-1]
        segs=identifyBouts(double(dl==val),mf);
        col=cf; if val==-1, col=cb; end
        drawn=false;
% Loop through data points
        for s=1:size(segs,1)
% Check condition before proceeding
            if segs(s,3)==0, continue; end
            yl=ylim(ax);
            h=fill(ax,[t(segs(s,1)) t(segs(s,2)) t(segs(s,2)) t(segs(s,1))], ...
                   [yl(1) yl(1) yl(2) yl(2)],col,'EdgeColor','none','FaceAlpha',0.3);
% Check condition before proceeding
            if ~drawn
% Check condition before proceeding
                if val==1, set(h,'DisplayName','Forward'); else, set(h,'DisplayName','Backward'); end
                drawn=true;
            else, set(h,'HandleVisibility','off'); end
        end
    end
end
% Define main function and return values
function out = ternary(c,a,b); if c, out=a; else, out=b; end; end
% Define main function and return values
function v = getAttrFallback(node, attrs)
    v='';
% Loop through data points
    for a=attrs
% Check condition before proceeding
        if node.hasAttribute(a{1})
            v=strtrim(char(node.getAttribute(a{1})));
% Check condition before proceeding
            if ~isempty(v), return; end
        end
    end
end
% Define main function and return values
function loc = readLocalXYZ(pt)
    loc=[];
% Loop through data points
    for a={'pos_b','pos_s','pos','position'}
% Check condition before proceeding
        if pt.hasAttribute(a{1})
            tmp=sscanf(char(pt.getAttribute(a{1})),'
% Check condition before proceeding
            if numel(tmp)>=3, loc=tmp(1:3)'; return; end
        end
    end
    tmp=sscanf(strtrim(char(pt.getTextContent)),'
% Check condition before proceeding
    if numel(tmp)>=3, loc=tmp(1:3)'; end
end
% Define main function and return values
function vr = quatRot(q, v)
    q=double(q(:).')/norm(double(q(:))); v=double(v(:).');
    w=q(1);x=q(2);y=q(3);z=q(4);
    R=[1-2*(y^2+z^2),2*(x*y-z*w),2*(x*z+y*w);
       2*(x*y+z*w),1-2*(x^2+z^2),2*(y*z-x*w);
       2*(x*z-y*w),2*(y*z+x*w),1-2*(x^2+y^2)];
    vr=(R*v(:)).';
end