%% -------------------------
% Main Script: ECG DSP Pipeline
% --------------------------

clc; clear; close all;

%% 1️⃣ Load & Filter ECG
% This function will:
% - load MIT-BIH .dat file
% - convert to mV
% - return unfiltered and filtered ECG
[t, ecg_raw, ecg_filt, Fs] = processECG('100');  

%% 2️⃣ R-Peak Detection
% This function will:
% - detect R-peaks from filtered ECG
% - return indices of R-peaks
R_locs = detectRPeaks(ecg_filt, Fs);  

%% 3️⃣ Extract One Clean ECG Cycle
% This function will:
% - take first two R-peaks
% - return one-cycle ECG and corresponding time vector
[t_cycle, one_cycle] = extractCycle(ecg_filt, R_locs, t);  

%% 4️⃣ Calculate Heart Rate (BPM) and HRV
% This function will:
% - calculate BPM using 10-sec window
% - calculate HRV (SDNN and RMSSD)
[BPM, SDNN, RMSSD] = computeMetrics(R_locs, Fs);  

%% 5️⃣ Plot Dashboard
% This function will:
% - plot filtered ECG (real-time style)
% - plot one-cycle ECG
% - display BPM and HRV values
plotECGDashboard(t, ecg_filt, t_cycle, one_cycle, BPM, SDNN, RMSSD);