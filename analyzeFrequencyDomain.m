function [BPM_freq, error_pct] = analyzeFrequencyDomain(ecg_signal, Fs, BPM_time)
    % Identifies cardiac components and verifies Heart Rate via FFT.

    N = length(ecg_signal);
    Y = fft(ecg_signal);
    f = (0:N-1)*(Fs/N);
    mag = abs(Y)/N;

    % Limit analysis to the positive spectrum up to 100Hz for clarity
    idx = f > 0 & f < 100;
    f_plot = f(idx);
    mag_plot = mag(idx);

    % Find the dominant peak in the heart rate range (0.5 - 3.5 Hz)
    hr_range = (f_plot >= 0.6 & f_plot <= 3.5);
    [~, max_idx] = max(mag_plot(hr_range));
    f_sub = f_plot(hr_range);
    f_peak = f_sub(max_idx);

    BPM_freq = f_peak * 60;
    error_pct = abs(BPM_freq - BPM_time) / BPM_time * 100;

    % Visualization
    figure('Name', 'Task 1B: Frequency Domain Analysis', 'NumberTitle', 'off');
    subplot(2,1,1);
    plot(f_plot, mag_plot, 'Color', [0 0.45 0.74], 'LineWidth', 1.2);
    hold on;
    plot(f_peak, mag_plot(f_plot == f_peak), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
    title(['Magnitude Spectrum - Peak at ', num2str(f_peak, '%.2f'), ' Hz']);
    xlabel('Frequency (Hz)'); ylabel('|Y(f)|'); grid on;
    legend('ECG Spectrum', 'Heart Rate Peak');

    % Highlight Clinical Bands
    subplot(2,1,2);
    area(f_plot, mag_plot, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none'); hold on;
    % QRS Complex Band (1-40 Hz)
    qrs_idx = f_plot >= 1 & f_plot <= 40;
    area(f_plot(qrs_idx), mag_plot(qrs_idx), 'FaceColor', [1 0.8 0.8], 'DisplayName', 'QRS Energy (1-40Hz)');
    % P/T Waves Band (0.5-10 Hz)
    pt_idx = f_plot >= 0.5 & f_plot <= 10;
    plot(f_plot(pt_idx), mag_plot(pt_idx), 'b', 'LineWidth', 1.5, 'DisplayName', 'P/T Waves (0.5-10Hz)');
    
    title('Clinical Frequency Band Analysis');
    xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on; xlim([0 60]);
    legend('show');

    fprintf('Task 1B Results\n');
    fprintf('BPM (Time Domain): %.2f\n', BPM_time);
    fprintf('BPM (Freq Domain): %.2f\n', BPM_freq);
    fprintf('Percentage Error:  %.2f%%\n\n', error_pct);
end