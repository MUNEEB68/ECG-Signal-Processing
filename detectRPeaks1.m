function R_locs = detectRPeaks1(ecg_signal, Fs)

%% Derivative + Squaring (Pan-Tompkins style)
% No notch filter — signal is already pre-filtered before calling this function
ecg_diff = diff([ecg_signal(1); ecg_signal(:)]);  % pad first sample to keep length
ecg_squared = ecg_diff.^2;
ecg_smooth = movmean(ecg_squared, round(0.03*Fs));  % 30 ms moving average

%%Peak detection
minDistance = round(0.35*Fs);                % 350 ms minimum distance
peakHeight  = 0.15 * max(ecg_smooth);       % lower dynamic threshold

[~, R_locs_smooth] = findpeaks(ecg_smooth, ...
    'MinPeakHeight',    peakHeight, ...
    'MinPeakDistance',  minDistance);

%% Map back to original ECG signal
R_locs = zeros(size(R_locs_smooth));
window = round(0.05*Fs);  % ±50 ms search window around smoothed peak

for i = 1:length(R_locs_smooth)
    idx_start = max(R_locs_smooth(i) - window, 1);
    idx_end   = min(R_locs_smooth(i) + window, length(ecg_signal));
    idx_range = idx_start : idx_end;

    [~, localMax] = max(ecg_signal(idx_range));
    R_locs(i) = idx_range(localMax);
end

%%Remove duplicates (just in case)
R_locs = unique(R_locs);

%%Plot first 10 seconds for verification
segment = 1 : min(Fs*10, length(ecg_signal));

figure('Name','R-Peak Detection - First 10 sec','NumberTitle','off');
plot(segment/Fs, ecg_signal(segment), 'b', 'LineWidth', 1.5); hold on;

R_plot = R_locs(R_locs <= segment(end));
plot(R_plot/Fs, ecg_signal(R_plot), 'ro', ...
    'MarkerFaceColor', 'r', 'MarkerSize', 6);

xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('R-Peaks Detection (First 10 Seconds)');
grid on;
xlim([0 10]);
hold off;

end