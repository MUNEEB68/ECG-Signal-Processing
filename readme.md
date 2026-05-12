ECG Signal Processing (MATLAB)
=================================

This project is a MATLAB pipeline for ECG signal processing and analysis. It loads ECG data, performs filtering, detects R-peaks, computes heart-rate and HRV metrics, and visualizes results in a dashboard. It also includes frequency-domain analysis, classical filtering comparisons, adaptive motion artifact removal, and multi-lead consistency checks.

Key Features
------------
- Time-domain ECG processing with bandpass filtering.
- R-peak detection and cycle extraction.
- HR and HRV metrics (BPM, SDNN, RMSSD).
- Frequency-domain verification of heart rate via FFT.
- Classical FIR/IIR filtering demos and SNR comparison.
- Adaptive motion artifact removal using STFT and wavelet denoising.
- Multi-lead timing consistency analysis and phase distortion demo.
- Rich visualization via a custom dashboard.

Project Structure
-----------------
- main_integrated.m: End-to-end pipeline entry point.
- processECG.m: Load raw ECG from a .dat file, filter it, and plot.
- detectRPeaks1.m: R-peak detection pipeline.
- extractCycle.m: Extract a single cardiac cycle.
- computeMetrics.m: Compute BPM, SDNN, RMSSD.
- plotECGDashboard.m: Visualization dashboard.
- analyzeFrequencyDomain.m: FFT-based heart-rate verification.
- filterClassical.m: Classical FIR/IIR filtering and SNR comparison.
- denoiseAdaptive.m: Motion artifact analysis and wavelet denoising.
- checkLeadConsistency.m: Multi-lead timing analysis.

Data Requirements
-----------------
The pipeline expects MIT-BIH record files in the working directory.
- A .dat file is required (e.g., 200.dat).
- The main script sets record = '200' by default.

If you have a different record available, edit the record ID in main_integrated.m to match your file name (without extension).

Optional local files:
- ecg.csv and 100.hea are present in the repository but are not used by the MATLAB scripts as written.

How To Run
----------
1) Open MATLAB and set the current folder to this repository.
2) Ensure your MIT-BIH .dat file is present in the folder.
3) Run the main script:
	- main_integrated.m

The script will create several figures and print metrics in the command window.

Outputs
-------
- ECG dashboard showing filtered signal, R-peaks, and HRV metrics.
- FFT plots highlighting cardiac frequency components.
- Filtering comparisons (time and frequency domain).
- Motion artifact detection plots and wavelet denoising results.
- Multi-lead timing distortion analysis and correlation summary.

Notes
-----
- Sampling rate is assumed to be 360 Hz (MIT-BIH standard).
- Some plots are intentionally verbose for report-quality screenshots.
- If you do not have record 200, change the record ID in main_integrated.m.

License
-------
Add your preferred license here.