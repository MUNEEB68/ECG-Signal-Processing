function R_locs = detectRPeaks1(ecg_signal, Fs)

%% Differentiate and square to emphasize sharp QRS changes
ecg_diff    = diff([ecg_signal(1); ecg_signal(:)]);
ecg_squared = ecg_diff .^ 2;

%% Smooth the energy signal with a short moving window (150 ms)
win_integ   = round(0.150 * Fs);          % 150 ms window
ecg_smooth  = movmean(ecg_squared, win_integ);

%% Build a local threshold so it adapts to amplitude drift
win_thresh  = round(1.0 * Fs);            % 1 s sliding window
local_max   = movmax(ecg_smooth, win_thresh);
threshold   = 0.2 * local_max;           % keep only stronger peaks

%% Detect candidate peaks on the smoothed/gated signal
minDistance = round(0.350 * Fs);          % enforce minimum RR distance (350 ms)

% Gate the signal so sub-threshold regions do not produce peaks
above = ecg_smooth > threshold;
ecg_gated = ecg_smooth .* above;          % zero out low-energy parts

[~, R_locs_smooth] = findpeaks(ecg_gated, ...
    'MinPeakDistance', minDistance);

%% Refine each candidate by searching the raw ECG in a +/-60 ms neighborhood
window  = round(0.060 * Fs);
R_locs  = zeros(size(R_locs_smooth));

for i = 1:length(R_locs_smooth)
    idx_start = max(R_locs_smooth(i) - window, 1);
    idx_end   = min(R_locs_smooth(i) + window, length(ecg_signal));
    idx_range = idx_start : idx_end;
    [~, localMax] = max(ecg_signal(idx_range));
    R_locs(i)  = idx_range(localMax);
end

%% Remove repeated indices after refinement
R_locs = unique(R_locs);

%% Quick sanity-check plot for the first 10 seconds
segment = 1 : min(Fs * 10, length(ecg_signal));

figure('Name','R-Peak Detection - First 10 sec','NumberTitle','off');
plot(segment/Fs, ecg_signal(segment), 'b', 'LineWidth', 1.5); hold on;

R_plot = R_locs(R_locs <= segment(end));
plot(R_plot/Fs, ecg_signal(R_plot), 'ro', ...
    'MarkerFaceColor', 'r', 'MarkerSize', 6);

xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('R-Peak Detection (First 10 Seconds)');
grid on;
xlim([0 10]);
hold off;

end
