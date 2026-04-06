function [t_cycle, one_cycle] = extractCycle(ecg_filt, R_locs, t)

% extract first two R-peak indices
if length(R_locs) < 3
    error('Need at least 3 R-peaks to extract a clean cycle');
end

R1 = R_locs(3); % first R-peak (skip first, may be partial)
R2 = R_locs(4); % second R-peak

% extract the ECG cycle between R1 and R2
one_cycle = ecg_filt(R1:R2);
t_cycle = t(R1:R2) - t(R1); % time vector starting at 0 for the cycle

% plot the one-cycle ECG
figure('Name','One ECG Cycle','NumberTitle','off');
plot(t_cycle, one_cycle, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Extracted One ECG Cycle');
grid on;

end