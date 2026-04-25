record = '100';
[t, ecg_raw, ecg_filt] = processECG(record);
%find the R-peaks in the filtered ECG signal
Fs = 360;  % sampling frequency
R_locs =  detectRPeaks1(ecg_filt, Fs); % get R-peak locations (indices)
[t_cycle, one_cycle] = extractCycle(ecg_filt, R_locs, t); % extract one ECG cycle between first two R-peaks
[BPM, SDNN, RMSSD] = computeMetrics(R_locs, Fs);  
plotECGDashboard(t, ecg_filt, t_cycle, one_cycle, BPM, SDNN, RMSSD,R_locs)
