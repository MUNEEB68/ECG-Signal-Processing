function [t, ecg_unfiltered, ecg_filtered] = processECG(record)


%% File Paths 
dat_file = [record '.dat'];
atr_file = [record '.atr'];  %#ok<NASGU> not used but kept for reference

%%Load .dat file ---
fid = fopen(dat_file, 'r');
raw = fread(fid, [2, inf], 'int16')';  % 2 leads, rows = samples
fclose(fid);

%% Metadata
Fs = 360;                 % Sampling frequency
baseline = [1024, 1024];  % baselines for MLII and V5
gain = [200, 200];        % gain to convert to mV

%% Convert digital units to mV 
ecg_signal(:,1) = (raw(:,1) - baseline(1)) / gain(1);  % MLII
ecg_signal(:,2) = (raw(:,2) - baseline(2)) / gain(2);  % V5

%% Time vector 
t = (0:length(ecg_signal)-1)/Fs;

%%  Unfiltered ECG (Lead MLII) 
ecg_unfiltered = ecg_signal(:,1);

%%  Plot unfiltered ECG (first 10 sec)
segment = 1 : Fs*10;
figure('Name',['MIT-BIH Record ', record, ' - Unfiltered ECG'], 'NumberTitle','off');
plot(t(segment), ecg_unfiltered(segment), 'b', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title(['MIT-BIH Record ', record, ' - Lead MLII (Unfiltered)']);
grid on;
xlim([0 10]);

%% FFT for bandwidth analysis
N = length(ecg_unfiltered);
Y = fft(ecg_unfiltered);
f_full = (-N/2:N/2-1)*(Fs/N);   % frequency vector
Y_shifted = fftshift(Y)/N;

figure('Name',['MIT-BIH Record ', record, ' - FFT Spectrum'], 'NumberTitle','off');
plot(f_full, abs(Y_shifted), 'b', 'LineWidth', 1.2);
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title(['Full Spectrum FFT of MIT-BIH Record ', record, ' - Lead MLII']);
grid on;
xlim([-50 50]);

%% Bandpass Filter 0.5 - 40 Hz
[b,a] = butter(2, [0.5 40]/(Fs/2), 'bandpass');  % 2nd-order Butterworth
ecg_filtered = filtfilt(b, a, ecg_unfiltered);

%% Plot filtered ECG (first 10 sec)
figure('Name',['MIT-BIH Record ', record, ' - Filtered ECG'], 'NumberTitle','off');
plot(t(segment), ecg_filtered(segment), 'b', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title(['MIT-BIH Record ', record, ' - Lead MLII (Filtered)']);
grid on;
xlim([0 10]);

end