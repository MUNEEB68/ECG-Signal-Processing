function plotECGDashboard(t, ecg_filt, t_cycle, one_cycle, BPM, SDNN, RMSSD, R_locs)
% plotECGDashboard  Display a real-time-style ECG analysis dashboard.
%
%   plotECGDashboard(t, ecg_filt, t_cycle, one_cycle, BPM, SDNN, RMSSD, R_locs)
%
%   INPUTS
%     t          – time vector for full ECG signal (seconds)
%     ecg_filt   – filtered ECG amplitude vector (same length as t)
%     t_cycle    – time vector for one representative cycle (relative to R-peak)
%     one_cycle  – amplitude vector for one cycle (same length as t_cycle)
%     BPM        – scalar heart rate in beats per minute
%     SDNN       – scalar HRV metric: SD of NN intervals (ms)
%     RMSSD      – scalar HRV metric: root-mean-square of successive differences (ms)
%     R_locs     – indices into t/ecg_filt where R-peaks occur
%
%   EXAMPLE
%     % Generate synthetic data for a quick demo
%     plotECGDashboard([], [], [], [], [], [], [], []);

% ── If called with no arguments, run the built-in demo ────────────────────
if nargin == 0 || isempty(t)
    runDemo();
    return
end

% ─────────────────────────────────────────────────────────────────────────
%  FIGURE SETUP
% ─────────────────────────────────────────────────────────────────────────
fig = figure('Name','ECG Dashboard', ...
             'Color',[0.12 0.13 0.15], ...
             'Units','normalized', ...
             'Position',[0.05 0.08 0.90 0.84], ...
             'NumberTitle','off', ...
             'MenuBar','none', ...
             'ToolBar','figure');

% ─────────────────────────────────────────────────────────────────────────
%  COLOUR PALETTE  (dark clinical theme)
% ─────────────────────────────────────────────────────────────────────────
C.bg        = [0.12 0.13 0.15];   % figure background
C.panel     = [0.17 0.19 0.22];   % panel face
C.panelEdge = [0.30 0.33 0.38];   % panel edge / grid
C.ecg       = [0.20 0.70 0.95];   % main ECG trace (cyan-blue)
C.rpeak     = [1.00 0.35 0.35];   % R-peak markers (red)
C.cycle     = [0.25 0.90 0.60];   % one-cycle trace (green)
C.txt       = [0.95 0.97 1.00];   % primary text
C.txtDim    = [0.55 0.60 0.68];   % secondary/dim text
C.accent    = [1.00 0.80 0.20];   % accent / BPM value (amber)
C.hrv       = [0.55 0.85 1.00];   % HRV value colour
C.resultBg  = [0.10 0.14 0.18];   % results box background

% ─────────────────────────────────────────────────────────────────────────
%  TITLE BAR (uicontrol annotation)
% ─────────────────────────────────────────────────────────────────────────
annotation(fig,'textbox',[0 0.95 1 0.05], ...
    'String','  ♥  ECG MONITORING DASHBOARD', ...
    'Color',C.txt, ...
    'BackgroundColor',[0.08 0.09 0.11], ...
    'EdgeColor','none', ...
    'FontName','Courier New', ...
    'FontSize',13, ...
    'FontWeight','bold', ...
    'VerticalAlignment','middle');

annotation(fig,'textbox',[0.75 0.95 0.25 0.05], ...
    'String',sprintf('  %s  ', datestr(now,'HH:MM:SS  dd-mmm-yyyy')), ...
    'Color',C.txtDim, ...
    'BackgroundColor',[0.08 0.09 0.11], ...
    'EdgeColor','none', ...
    'FontName','Courier New', ...
    'FontSize',9, ...
    'HorizontalAlignment','right', ...
    'VerticalAlignment','middle');

% ─────────────────────────────────────────────────────────────────────────
%  LAYOUT  (using subplot positions manually for fine control)
%
%   [left  bottom  width  height]   (normalised figure units)
%
%   Row 1 (top):    Full ECG signal               – wide strip
%   Row 2 (bottom): One-cycle panel (left 40%)
%                   Results summary  (right 55%)
% ─────────────────────────────────────────────────────────────────────────
pad = 0.03;
topH    = 0.38;   % height of top panel
botH    = 0.34;   % height of bottom panels
botBot  = 0.09;   % y-start of bottom row

ax_ecg   = axes('Parent',fig, 'Units','normalized', ...
    'Position',[pad, botBot+botH+0.06, 1-2*pad, topH]);

ax_cycle = axes('Parent',fig, 'Units','normalized', ...
    'Position',[pad, botBot, 0.38, botH]);

% Results panel (right side, bottom row)
resPanelPos = [0.44, botBot-0.01, 0.53, botH+0.02];

% ─────────────────────────────────────────────────────────────────────────
%  PANEL 1 – FULL ECG SIGNAL
% ─────────────────────────────────────────────────────────────────────────
axes(ax_ecg);
styliseAxes(ax_ecg, C);

% Plot ECG
plot(ax_ecg, t, ecg_filt, 'Color', C.ecg, 'LineWidth', 1.2); hold on;

% Overlay R-peak markers using provided R_locs indices
if ~isempty(R_locs)
    stem(ax_ecg, t(R_locs), ecg_filt(R_locs), ...
        'Color', C.rpeak, ...
        'MarkerFaceColor', C.rpeak, ...
        'MarkerSize', 5, ...
        'LineWidth', 0.8, ...
        'BaseValue', min(ecg_filt));
end

xlabel(ax_ecg, 'Time (s)', 'Color', C.txtDim, 'FontSize', 9);
ylabel(ax_ecg, 'Amplitude', 'Color', C.txtDim, 'FontSize', 9);
title(ax_ecg, 'ECG Signal — Real Time', ...
    'Color', C.txt, 'FontSize', 11, 'FontWeight', 'bold');

% Subtle scan-line grid
grid(ax_ecg, 'on');
ax_ecg.GridColor       = C.panelEdge;
ax_ecg.GridAlpha       = 0.35;
ax_ecg.MinorGridColor  = C.panelEdge;
ax_ecg.MinorGridAlpha  = 0.15;
ax_ecg.XMinorGrid      = 'on';
ax_ecg.YMinorGrid      = 'on';
xlim(ax_ecg, [t(1), min(t(1) + 10, t(end))]);

% Legend
legend(ax_ecg, {'ECG','R-peaks'}, ...
    'TextColor', C.txtDim, ...
    'Color', C.panel, ...
    'EdgeColor', C.panelEdge, ...
    'FontSize', 8, ...
    'Location','northeast');

% ─────────────────────────────────────────────────────────────────────────
%  PANEL 2 – ONE CYCLE
% ─────────────────────────────────────────────────────────────────────────
axes(ax_cycle);
styliseAxes(ax_cycle, C);

plot(ax_cycle, t_cycle, one_cycle, 'Color', C.cycle, 'LineWidth', 1.8);
hold on;

% Mark R-peak of cycle
[~, rpIdx] = max(one_cycle);
plot(ax_cycle, t_cycle(rpIdx), one_cycle(rpIdx), ...
    'v', 'Color', C.rpeak, ...
    'MarkerFaceColor', C.rpeak, 'MarkerSize', 8);

% Label PQRST waves
labelPQRST(ax_cycle, t_cycle, one_cycle, C);

xlabel(ax_cycle, 'Time relative to R-peak (s)', 'Color',C.txtDim,'FontSize',9);
ylabel(ax_cycle, 'Amplitude', 'Color',C.txtDim,'FontSize',9);
title(ax_cycle, 'ECG Signal — One Cycle', ...
    'Color',C.txt,'FontSize',11,'FontWeight','bold');
grid(ax_cycle,'on');
ax_cycle.GridColor  = C.panelEdge;
ax_cycle.GridAlpha  = 0.3;

% ─────────────────────────────────────────────────────────────────────────
%  PANEL 3 – RESULTS SUMMARY BOX
% ─────────────────────────────────────────────────────────────────────────
ax_res = axes('Parent',fig,'Units','normalized', ...
    'Position', resPanelPos, ...
    'XTick',[],'YTick',[],'Box','on');
ax_res.Color       = C.resultBg;
ax_res.XColor      = C.panelEdge;
ax_res.YColor      = C.panelEdge;
xlim(ax_res,[0 1]); ylim(ax_res,[0 1]);

% ── Header ────────────────────────────────────────────────────────────────
text(0.50, 0.90, 'RESULTS', ...
    'Parent',ax_res,'Units','normalized', ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'Color',C.txt,'FontName','Courier New','FontSize',13,'FontWeight','bold');

% Divider line
annotation(fig,'line', ...
    [resPanelPos(1)+0.02, resPanelPos(1)+resPanelPos(3)-0.02], ...
    [resPanelPos(2)+resPanelPos(4)*0.83, resPanelPos(2)+resPanelPos(4)*0.83], ...
    'Color',C.panelEdge,'LineWidth',1);

% ── Heart Rate ─────────────────────────────────────────────────────────
text(0.08, 0.66, 'Heart Rate', ...
    'Parent',ax_res,'Units','normalized', ...
    'Color',C.txtDim,'FontName','Courier New','FontSize',11);
text(0.90, 0.66, sprintf('%.1f  BPM', BPM), ...
    'Parent',ax_res,'Units','normalized', ...
    'HorizontalAlignment','right', ...
    'Color',C.accent,'FontName','Courier New','FontSize',18,'FontWeight','bold');

% ── SDNN ──────────────────────────────────────────────────────────────
text(0.08, 0.46, 'HRV  (SDNN)', ...
    'Parent',ax_res,'Units','normalized', ...
    'Color',C.txtDim,'FontName','Courier New','FontSize',11);
text(0.90, 0.46, sprintf('%.1f  ms', SDNN), ...
    'Parent',ax_res,'Units','normalized', ...
    'HorizontalAlignment','right', ...
    'Color',C.hrv,'FontName','Courier New','FontSize',18,'FontWeight','bold');

% ── RMSSD ─────────────────────────────────────────────────────────────
text(0.08, 0.28, 'HRV  (RMSSD)', ...
    'Parent',ax_res,'Units','normalized', ...
    'Color',C.txtDim,'FontName','Courier New','FontSize',11);
text(0.90, 0.28, sprintf('%.1f  ms', RMSSD), ...
    'Parent',ax_res,'Units','normalized', ...
    'HorizontalAlignment','right', ...
    'Color',C.hrv,'FontName','Courier New','FontSize',18,'FontWeight','bold');

% ── Status badge ──────────────────────────────────────────────────────
status = classifyHR(BPM);
annotation(fig,'textbox', ...
    [resPanelPos(1)+0.08, resPanelPos(2)+0.01, resPanelPos(3)-0.16, 0.055], ...
    'String', ['  STATUS :  ' status '  '], ...
    'Color', statusColor(status), ...
    'BackgroundColor', [0.08 0.10 0.12], ...
    'EdgeColor', statusColor(status), ...
    'LineWidth', 1.2, ...
    'FontName','Courier New', ...
    'FontSize',10,'FontWeight','bold', ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle');

% ─────────────────────────────────────────────────────────────────────────
%  BOTTOM ANNOTATION BAR
% ─────────────────────────────────────────────────────────────────────────
annotation(fig,'textbox',[0 0 1 0.05], ...
    'String','  BPM updated every 10 s  |  HRV updated every 60 s  |  Filtered signal displayed', ...
    'Color', C.txtDim, ...
    'BackgroundColor',[0.08 0.09 0.11], ...
    'EdgeColor','none', ...
    'FontName','Courier New', ...
    'FontSize', 8, ...
    'VerticalAlignment','middle');

end  % plotECGDashboard


% =========================================================================
%  LOCAL HELPERS
% =========================================================================

function styliseAxes(ax, C)
% Apply consistent dark-theme styling to an axes object.
    ax.Color      = C.panel;
    ax.XColor     = C.txtDim;
    ax.YColor     = C.txtDim;
    ax.FontName   = 'Courier New';
    ax.FontSize   = 9;
    ax.LineWidth  = 0.8;
    ax.Box        = 'on';
    ax.TickDir    = 'out';
    set(ax,'XGrid','on','YGrid','on', ...
           'GridColor',C.panelEdge,'GridAlpha',0.25);
end



function labelPQRST(ax, t, ecg, C)
% Heuristic PQRST labelling on a single-cycle ECG snippet.
%   Assumes the cycle is centred on the R-peak.
    N    = numel(ecg);
    rng  = range(ecg);
    fs   = 1 / mean(diff(t));

    [Rval, Ridx] = max(ecg);

    % S wave: minimum after R within ~180 ms
    sWin = Ridx : min(N, Ridx + round(0.18*fs));
    [Sval, SidxRel] = min(ecg(sWin));
    Sidx = sWin(1) + SidxRel - 1;

    % Q wave: minimum before R within ~80 ms
    qWin = max(1, Ridx - round(0.08*fs)) : Ridx;
    [Qval, QidxRel] = min(ecg(qWin));
    Qidx = qWin(1) + QidxRel - 1;

    % P wave: max before Q within ~200 ms
    pWin = max(1, Qidx - round(0.20*fs)) : Qidx;
    [Pval, PidxRel] = max(ecg(pWin));
    Pidx = pWin(1) + PidxRel - 1;

    % T wave: max after S within ~400 ms
    tWin = Sidx : min(N, Sidx + round(0.40*fs));
    [Tval, TidxRel] = max(ecg(tWin));
    Tidx = tWin(1) + TidxRel - 1;

    off = 0.06 * rng;   % vertical label offset
    lblArgs = {'Color',C.txtDim,'FontName','Courier New','FontSize',9,'FontWeight','bold'};

    text(ax, t(Pidx), Pval + off, 'P', lblArgs{:}, 'HorizontalAlignment','center');
    text(ax, t(Qidx), Qval - off, 'Q', lblArgs{:}, 'HorizontalAlignment','center');
    text(ax, t(Ridx), Rval + off, 'R', 'Color',C.rpeak, ...
        'FontName','Courier New','FontSize',9,'FontWeight','bold', ...
        'HorizontalAlignment','center');
    text(ax, t(Sidx), Sval - off, 'S', lblArgs{:}, 'HorizontalAlignment','center');
    text(ax, t(Tidx), Tval + off, 'T', lblArgs{:}, 'HorizontalAlignment','center');
end

% -------------------------------------------------------------------------
function s = classifyHR(bpm)
    if bpm < 60
        s = 'BRADYCARDIA';
    elseif bpm <= 100
        s = 'NORMAL SINUS RHYTHM';
    else
        s = 'TACHYCARDIA';
    end
end

% -------------------------------------------------------------------------
function c = statusColor(status)
    switch status
        case 'NORMAL SINUS RHYTHM', c = [0.25 0.90 0.50];
        case 'BRADYCARDIA',          c = [1.00 0.80 0.20];
        otherwise,                   c = [1.00 0.35 0.35];
    end
end

% =========================================================================
%  DEMO  (called when no arguments are supplied)
% =========================================================================
function runDemo()
    fs   = 500;           % Hz
    dur  = 15;            % seconds
    t    = (0 : 1/fs : dur - 1/fs)';
    bpm  = 72;
    RR   = 60 / bpm;      % seconds

    % Synthesise a plausible ECG via summed Gaussians (PQRST morphology)
    ecg = zeros(size(t));
    peaks = RR/2 : RR : dur;
    for rp = peaks
        ecg = ecg + ecgPulse(t, rp, fs);
    end
    % Add mild noise
    rng(42);
    ecg = ecg + 0.03 * randn(size(ecg));
    % Light band-pass: simple moving average subtraction for baseline
    ecg_filt = ecg - movmean(ecg, round(0.4*fs));

    % One cycle centred on R = peaks(5)
    refR   = peaks(min(5, numel(peaks)));
    winSec = [-0.3, 0.5];
    idx    = t >= refR + winSec(1) & t <= refR + winSec(2);
    t_cycle   = t(idx) - refR;
    one_cycle = ecg_filt(idx);

    SDNN  = 45.2;
    RMSSD = 38.7;

    % Compute R_locs from known peak times for the demo
    R_locs = arrayfun(@(rp) find(t >= rp, 1, 'first'), peaks);

    plotECGDashboard(t, ecg_filt, t_cycle, one_cycle, bpm, SDNN, RMSSD, R_locs);
end

% -------------------------------------------------------------------------
function y = ecgPulse(t, t0, ~)
% Returns one synthetic PQRST complex centred at t0.
    y =   0.20 * gaussPeak(t, t0 - 0.20, 0.030) ...   % P
        - 0.15 * gaussPeak(t, t0 - 0.05, 0.012) ...   % Q
        + 1.00 * gaussPeak(t, t0,         0.015) ...   % R
        - 0.30 * gaussPeak(t, t0 + 0.04, 0.014) ...   % S
        + 0.35 * gaussPeak(t, t0 + 0.20, 0.040);      % T
end

function y = gaussPeak(t, mu, sigma)
    y = exp(-0.5 * ((t - mu) / sigma).^2);
end
