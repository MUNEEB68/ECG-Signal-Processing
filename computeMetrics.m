function [BPM, SDNN, RMSSD] = computeMetrics(R_locs, Fs)

%compute BPM for the 10 second window
% calculate the number of R-peaks in the first 10 seconds
window_duration = 10; % seconds
window_samples = window_duration * Fs; % number of samples in 10 seconds
R_in_window = R_locs(R_locs <= window_samples); % R-peaks within first 10 seconds
BPM = length(R_in_window) * 6; % convert to BPM (6 times the number in 10 seconds)

% Calculate HRV in milliseconds after one minute of data
minute_samples = Fs * 60; % number of samples in one minute
R_in_minute = R_locs(R_locs <= minute_samples); % R-peaks within first minute

if length(R_in_minute) < 2
    error('Not enough R-peaks to compute HRV');
end

%find the RR interval in seconds
RR_interval = diff(R_in_minute)/Fs;
% Convert RR intervals to milliseconds
RR_interval_ms = RR_interval * 1000;
%calculate SDNN and RMSSD
SDNN = std(RR_interval_ms); % standard deviation of RR intervals
RMSSD = sqrt(mean(diff(RR_interval_ms).^2)); % root mean square of successive differences

disp(['BPM: ', num2str(BPM)]);
disp(['SDNN: ', num2str(SDNN), ' ms']);
disp(['RMSSD: ', num2str(RMSSD), ' ms']);

end