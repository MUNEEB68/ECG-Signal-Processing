function ecg_clean = denoiseAdaptive(ecg_raw, Fs)
    % Stream B: Advanced Motion Artifact Removal & STFT Analysis
    
    t = (0:length(ecg_raw)-1)/Fs;
    
    % Simulate/Identify Motion Artifact 
    % We add a non-stationary swing to the signal to demonstrate filter failure
    motion_artifact = 0.5 * sin(2*pi*0.1*t + 0.5*t.^2)'; % Frequency changes over time
    ecg_noisy = ecg_raw + motion_artifact;

    % Fixed Filter Failure
    % Applying the High-Pass from Stream A
    [b, a] = butter(2, 0.5/(Fs/2), 'high');
    ecg_fixed = filtfilt(b, a, ecg_noisy);
    
    figure('Name', 'B.1 Fixed Filter Failure on Motion Artifact', 'NumberTitle', 'off');
    subplot(2,1,1); plot(t, ecg_noisy, 'r'); title('Raw Signal + Non-Stationary Motion Artifact'); xlim([10 20]);
    subplot(2,1,2); plot(t, ecg_fixed, 'b'); title('Result of Fixed High-Pass Filter (Artifact Still Present)'); xlim([10 20]);
    legend('Baseline remains unstable');

    %% STFT Spectrogram & Artifact Regions
    figure('Name', 'B.2 Spectrogram (STFT) Analysis', 'NumberTitle', 'off');
    window_len = 256;
    [s, f_stft, t_stft] = stft(ecg_noisy, Fs, 'Window', hamming(window_len), 'OverlapLength', 128);
    imagesc(t_stft, f_stft, abs(s)); axis xy; colorbar;
    ylim([0 60]); title('STFT Spectrogram - Artifact Regions Identified');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    % Draw an arrow to the low-freq artifact
    text(15, 2, '\leftarrow Motion Energy (Low Freq)', 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');

    %% Window Size Comparison
    figure('Name', 'B.3 STFT Window Length Comparison', 'NumberTitle', 'off');
    wins = [64, 256, 1024];
    for i = 1:3
        subplot(3,1,i);
        stft(ecg_noisy, Fs, 'Window', hamming(wins(i)), 'OverlapLength', wins(i)/2);
        ylim([0 60]); title(['Window Size: ', num2str(wins(i)), ' samples']);
    end

    %% Frame-Based Artifact Detection
    % We detect frames where the energy is significantly higher than average
    frame_size = 512;
    num_frames = floor(length(ecg_noisy)/frame_size);
    frame_energy = zeros(num_frames, 1);
    for i = 1:num_frames
        idx = (i-1)*frame_size + (1:frame_size);
        frame_energy(i) = sum(ecg_noisy(idx).^2);
    end
    threshold = mean(frame_energy) * 1.5;
    artifact_frames = find(frame_energy > threshold);

    figure('Name', 'B.4 Frame-Based Artifact Detection', 'NumberTitle', 'off');
    plot(t, ecg_noisy, 'Color', [0.7 0.7 0.7]); hold on;
    for i = artifact_frames'
        idx = (i-1)*frame_size + (1:frame_size);
        plot(t(idx), ecg_noisy(idx), 'r', 'LineWidth', 1.2);
    end
    title('Artifact Regions Detected (Red Markers)'); legend('Normal Signal', 'Artifact Detected'); xlim([10 30]);

    %% Wavelet Denoising (The "Improved" Method)
    % Using Wavelet Denoising as Method 2
    ecg_wavelet = wdenoise(ecg_noisy, 5, 'Wavelet', 'sym4');

    figure('Name', 'B.5 Before/After Method Comparison', 'NumberTitle', 'off');
    subplot(3,1,1); plot(t, ecg_noisy, 'r'); title('Original Noisy Signal'); xlim([15 20]);
    subplot(3,1,2); plot(t, ecg_fixed, 'k'); title('Method 1: Fixed Filter Result'); xlim([15 20]);
    subplot(3,1,3); plot(t, ecg_wavelet, 'g'); title('Method 2: Wavelet Denoising Result'); xlim([15 20]);

    %% Quantitative Comparison 
    % Metrics: SNR, Correlation with a clean segment, RMS Error
    % Assuming ecg_raw is the Ground Truth
    snr_fixed = snr(ecg_fixed, motion_artifact');
    snr_wave = snr(ecg_wavelet, motion_artifact');
    
    corr_fixed = corr(ecg_raw, ecg_fixed);
    corr_wave = corr(ecg_raw, ecg_wavelet);
    
    rmse_fixed = sqrt(mean((ecg_raw - ecg_fixed).^2));
    rmse_wave = sqrt(mean((ecg_raw - ecg_wavelet).^2));

    fprintf('SNR (dB)%.2f %.2f\n', snr_fixed, snr_wave);
    fprintf('Correlation %.4f %.4f\n', corr_fixed, corr_wave);
    fprintf('RMS Error %.4f %.4f\n', rmse_fixed, rmse_wave);
   
    
    ecg_clean = ecg_wavelet;
end
