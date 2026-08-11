function set = setting_demo()
% Settings for the synthetic demo recording.
%
% This file mirrors the structure of a real experiment's setting file
% (e.g. setting_exp1.m). Users should copy it and adjust values for their
% own experiment and screen setup.
%
% Usage:
%   set = setting_demo();

%% The sequence of messages within a trial
% Each string must appear exactly once per trial in the EyeLink message log.
% detect_epoch uses these to segment trials into epochs numbered 1..N.
set.msg = {'TRIALID','FixSrt','TarSrt','SacSrt','TrialEnd'};

%% Which eye to analyze
% 1 = left, 2 = right, 3 = binocular
set.eye = 2;

%% Screen geometry
% These must match the physical setup. Used for pixel-to-degree conversion.
set.screen.d    = 67.7;     % viewing distance, cm
set.screen.w    = 38;       % screen width, cm
set.screen.h    = 30.5;     % screen height, cm
set.screen.xres = 1280;     % horizontal resolution, px
set.screen.yres = 1024;     % vertical resolution, px

%% Saccade detection (IVT: velocity, acceleration, amplitude, duration)
% Saccades are identified as periods exceeding all four thresholds.
% References: Salvucci & Goldberg 2000; Erkelens & Vogels 1995
set.sac.vel_threshold  = 30;      % deg/s
set.sac.acc_threshold  = 8000;    % deg/s^2
set.sac.amp_threshold  = 0.25;    % deg
set.sac.dur_threshold  = 8;       % ms
set.sac.comb_threshold = 25;      % ms — merge saccades whose gap is shorter

%% Saccade selection criteria (used by event_selection functions)
set.sac.srt_err  = 2;        % start position within 2 dva of fixation cross
set.sac.end_err  = 3.5;      % end position within 3.5 dva of target
set.sac.aend_err = 2;        % end position must be > 2 dva from center
set.sac.msg      = [4 5];    % select saccades after these epoch messages
set.sac.rt       = [50 1200]; % valid reaction-time window, ms

%% Fixation detection (I-DT: dispersion, duration, velocity)
% References: Salvucci & Goldberg 2000; Widdel 1984
set.fix.disp_threshold = 1.5;    % deg — maximum gaze dispersion
set.fix.dur_threshold  = 30;     % ms  — minimum fixation duration
set.fix.vel_threshold  = 10;     % deg/s — maximum gaze velocity

%% Blink and artifact detection
% set.noise.blink_method:
%   1 = EyeLink default blink events
%   2 = EyeLink blinks, padded by blink_extend ms
%   3 = velocity-based (Nyström & Holmqvist 2010), uses blink_pvel
%   4 = noise-based (Hershman et al. 2018)
set.noise.blink_method = 2;
set.noise.blink_extend = 100;     % ms padding before and after each blink
set.noise.blink_pvel   = 8000;    % pupil velocity threshold (method 3 only)

set.noise.gaze_vel     = 1000;    % deg/s  — flag gaze velocity above this
set.noise.gaze_acc     = 100000;  % deg/s² — flag gaze acceleration above this
set.noise.pupil_sz     = 5;       % MADs   — flag extreme pupil size
set.noise.pupil_vel    = 100;     % MADs   — flag extreme pupil velocity

%% Drift correction
set.noise.baseline_ratio = 0.5;   % use this fraction of the pre-stimulus
                                   % fixation as the drift-correction baseline

%% Data cleaning
% set.clean.artifact — which artifact types to remove:
%   0 = all, 1 = blinks, 2 = missing data, 3 = off-screen gaze,
%   4 = extreme gaze velocity/acceleration, 5 = extreme pupil size,
%   6 = extreme pupil velocity
set.clean.artifact = 0;
set.clean.dist     = 50;          % ms — merge artifacts closer than this

%% Interpolation (for pupil data)
% set.interp.method: 1 = linear, 2 = spline
set.interp.method = 1;
set.interp.range  = 50;           % ms of clean data used on each side

%% Baseline correction (for pupil data)
set.bcorr.msg         = 2;        % baseline epoch = period between msg 2 and 3
set.bcorr.method      = 1;        % 1 = subtractive, 2 = divisive
set.bcorr.base_method = 2;        % 1 = mean, 2 = median of baseline samples

%% Plotting
set.plot.trial_srt = 1;           % first trial to plot
set.plot.trial_end = 5;           % last trial to plot

end
