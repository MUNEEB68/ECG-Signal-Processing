function [ecg_iir, ecg_fir] = filterClassical(ecg_raw, Fs)
    % Stream A: Complete Classical Filtering Analysis
    % Fixes dimension mismatch errors and provides all required screenshots.

    t = (0:length(ecg_raw)-1)/Fs;
    nfft = 4096; % Consistent FFT size to avoid dimension errors

    %% 1. Raw ECG with Noise Identified (SS #1)
    figure('Name', 'A.1 Raw ECG - Noise Identification', 'NumberTitle', 'off');
    plot(t, ecg_raw, 'k'); hold on;
    % Labels for the report
    text(2.2, max(ecg_raw(Fs*2:Fs*3))+0.2, '\leftarrow 60Hz Power-line Noise', 'Color', 'r', 'FontWeight', 'bold');
    text(4.0, min(ecg_raw(Fs*4:Fs*5))-0.3, '\leftarrow Baseline Wander', 'Color', 'b', 'FontWeight', 'bold');
    title('Raw ECG Signal with Visible Noise Identified');
    xlabel('Time (s)'); ylabel('Amplitude (mV)'); xlim([2 6]); grid on;

    %% 2. FFT Spectrum with Annotated Noise Peaks (SS #2)
    figure('Name', 'A.2 Raw FFT Spectrum - Annotated', 'NumberTitle', 'off');
    [P_raw, f_plot] = periodogram(ecg_raw, [], nfft, Fs);
    semilogy(f_plot, P_raw, 'k'); hold on;
    % Annotate 60Hz peak
    [~, idx60] = min(abs(f_plot-60));
    plot(f_plot(idx60), P_raw(idx60), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(62, P_raw(idx60), 'Mains Peak (60Hz)', 'Color', 'r', 'FontWeight', 'bold');
    title('Raw Signal FFT Magnitude Spectrum');
    xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)'); xlim([0 100]); grid on;

    %% 3. Filter Design: HP, Notch, LP (SS #3 & #4)
    % FIR Filters
    hp_filt = designfilt('highpassfir', 'FilterOrder', 100, 'CutoffFrequency', 0.5, 'SampleRate', Fs);
    notch_filt = designfilt('bandstopfir', 'FilterOrder', 100, 'CutoffFrequency1', 59, 'CutoffFrequency2', 61, 'SampleRate', Fs);
    lp_filt = designfilt('lowpassfir', 'FilterOrder', 100, 'CutoffFrequency', 45, 'SampleRate', Fs);

    % IIR Filter (for comparison)
    [b_iir, a_iir] = butter(4, [0.5 45]/(Fs/2), 'bandpass');

    % Open FVTool for Filter Response screenshots
    % Note: You can switch between Magnitude/Phase/Group Delay in these windows
    fvtool(hp_filt, 'Name', 'High-Pass FIR Filter Response');
    fvtool(notch_filt, 'Name', 'Notch FIR Filter Response');
    fvtool(lp_filt, 'Name', 'Low-Pass FIR Filter Response');

    %% 4. Group Delay Comparison (SS #4)
    figure('Name', 'A.4 Group Delay Comparison', 'NumberTitle', 'off');
    subplot(2,1,1); grpdelay(hp_filt, nfft, Fs); 
    title('FIR Filter: Constant Group Delay (Linear Phase)'); grid on;
    subplot(2,1,2); grpdelay(b_iir, a_iir, nfft, Fs); 
    title('IIR Filter: Variable Group Delay (Phase Distortion)'); grid on;

    %% 5. Apply Filtering & Comparisons (SS #5 & #6)
    % Process signal
    ecg_fir = filtfilt(hp_filt, ecg_raw);
    ecg_fir = filtfilt(notch_filt, ecg_fir);
    ecg_fir = filtfilt(lp_filt, ecg_fir);
    ecg_iir = filtfilt(b_iir, a_iir, ecg_raw);

    % Time Domain Comparison
    figure('Name', 'A.5 Before vs After - Time Domain', 'NumberTitle', 'off');
    subplot(2,1,1); plot(t, ecg_raw, 'Color', [0.6 0.6 0.6]); title('Raw Signal'); xlim([3 6]); ylabel('mV');
    subplot(2,1,2); plot(t, ecg_fir, 'b'); title('Cleaned Signal (Combined FIR Filters)'); xlim([3 6]); ylabel('mV');

    % Frequency Domain Comparison (FIXED SIZE MISMATCH)
    figure('Name', 'A.6 Before vs After - Frequency Domain', 'NumberTitle', 'off');
    [P_clean, ~] = periodogram(ecg_fir, [], nfft, Fs);
    semilogy(f_plot, P_raw, 'Color', [0.6 0.6 0.6], 'DisplayName', 'Raw Spectrum'); hold on;
    semilogy(f_plot, P_clean, 'b', 'LineWidth', 1, 'DisplayName', 'Cleaned Spectrum');
    title('Spectrum Comparison: Raw vs Cleaned'); 
    xlabel('Frequency (Hz)'); ylabel('dB/Hz'); xlim([0 100]); grid on; legend show;

    %% 6. SNR Computation Table (SS #7)
    snr_raw = snr(ecg_raw);
    snr_fir = snr(ecg_fir);
    
    fprintf('\n--- Stream A: SNR Computation Table ---\n');
    fprintf('Signal Condition | SNR (dB)\n');
    fprintf('-----------------|----------\n');
    fprintf('Raw ECG Signal   | %.2f\n', snr_raw);
    fprintf('FIR Cleaned ECG  | %.2f\n', snr_fir);
    fprintf('----------------------------\n');
end