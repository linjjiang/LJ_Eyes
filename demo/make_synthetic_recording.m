function [edf,set] = make_synthetic_recording(seed)
% MAKE_SYNTHETIC_RECORDING  Generate a synthetic eye-tracking recording.
%
% Produces the same 'edf' and 'set' structures that get_params, get_screen_size
% and load_sample would produce from a real EyeLink .edf file, so the rest of the
% pipeline can run without any participant data and without the Edf2Mat MEX build.
%
%   [edf,set] = make_synthetic_recording()      % default seed
%   [edf,set] = make_synthetic_recording(42)    % reproducible
%
% Ground truth, for use as a smoke test (see run_demo.m):
%   8 trials, 4 s each, 500 Hz
%   2 saccades per trial (outward at 1.2 s, return at 3.0 s) = 16 total
%   1 blink per trial at 2.2 s, 120 ms long = 8 total
%
% The signal is generated, not recorded. No human subject is involved.

if nargin < 1, seed = 7; end
rng(seed);

%% ------------------------------------------------------------------ setup
sample_rate = 500;              % Hz
ntrial      = 8;
trial_dur   = 4;                % s
nsamp_trial = trial_dur*sample_rate;
nsamp       = ntrial*nsamp_trial;

% recording parameters (what get_params would produce)
edf.record.sample_rate = sample_rate;
edf.record.eye         = 'right';
edf.record.mode        = 'CR';
edf.record.pupil_type  = 'area';

set.eye = 2;                    % right eye = column 2, EyeLink convention

% screen parameters (what get_screen_size(edf,1,60,37.7,30.2,1024,768) produces)
edf.screen.d    = 60;           % viewing distance, cm
edf.screen.w    = 37.7;         % screen width, cm
edf.screen.h    = 30.2;         % screen height, cm
edf.screen.xres = 1024;
edf.screen.yres = 768;
edf.screen.xpix_per_deg = tand(1/2)*edf.screen.d*2/edf.screen.w*edf.screen.xres;
edf.screen.ypix_per_deg = tand(1/2)*edf.screen.d*2/edf.screen.h*edf.screen.yres;

%% ------------------------------------------------------- generate samples
time = (0:nsamp-1)'*(1000/sample_rate);        % ms, like EyeLink
xc   = edf.screen.xres/2;
yc   = edf.screen.yres/2;

x = xc*ones(nsamp,1);
y = yc*ones(nsamp,1);
p = 1200*ones(nsamp,1);                        % pupil area, EyeLink units

sac_amp_deg = 12;                              % saccade amplitude, degrees
sac_dur     = 0.045;                           % saccade duration, s
sac_amp_pix = sac_amp_deg*edf.screen.xpix_per_deg;

blink_onsets = zeros(ntrial,1);
sac_onsets   = zeros(ntrial,2);

for tr = 1:ntrial
    off = (tr-1)*nsamp_trial;                  % sample offset of this trial

    % target alternates left/right so saccades differ trial to trial
    direction = (-1)^tr;

    % --- outward saccade at 1.2 s, return saccade at 3.0 s ---------------
    for k = 1:2
        if k == 1
            t_on = 1.2; from = 0;              to = direction*sac_amp_pix;
        else
            t_on = 3.0; from = direction*sac_amp_pix; to = 0;
        end
        i0 = off + round(t_on*sample_rate);
        i1 = i0 + round(sac_dur*sample_rate);
        sac_onsets(tr,k) = i0;

        % minimum-jerk displacement profile (realistic velocity profile)
        tau = linspace(0,1,i1-i0+1)';
        prof = 10*tau.^3 - 15*tau.^4 + 6*tau.^5;
        x(i0:i1)   = xc + from + (to-from)*prof;
        x(i1+1:off+nsamp_trial) = xc + to;
    end

    % --- blink at 2.2 s, 120 ms ------------------------------------------
    b0 = off + round(2.2*sample_rate);
    b1 = b0 + round(0.120*sample_rate);
    blink_onsets(tr) = b0;
    p(b0:b1) = 0;                              % pupil lost: 0 = missing
    x(b0:b1) = 0;                              % gaze garbage during blink
    y(b0:b1) = 0;
end

% slow drift + measurement noise on top of the clean signal
drift = 12*sin(2*pi*(1:nsamp)'/(nsamp/3));
x = x + drift + 1.2*randn(nsamp,1);
y = y + 0.6*drift + 1.2*randn(nsamp,1);
p = p + 25*sin(2*pi*(1:nsamp)'/(nsamp/5)) + 8*randn(nsamp,1);

% re-apply the blink flats, so noise does not fill them back in
for tr = 1:ntrial
    b0 = blink_onsets(tr); b1 = b0 + round(0.120*sample_rate);
    p(b0:b1) = 0; x(b0:b1) = 0; y(b0:b1) = 0;
end

%% ----------------------------------------- pack into the 'edf' structure
% Two columns: column 1 = left eye (not recorded), column 2 = right eye.
% -32768 is the EyeLink sentinel for "no data", which is what the toolbox
% checks for elsewhere (see demo/training_spring2023/tutorial_setting.m).
dead = -32768*ones(nsamp,1);

edf.samples.time       = time;
edf.samples.x          = [dead x];
edf.samples.y          = [dead y];
edf.samples.pupil_size = [dead p];
edf.samples.ntrial     = ntrial;

edf.samples.pix_per_deg_x = edf.screen.xpix_per_deg*ones(nsamp,1);
edf.samples.pix_per_deg_y = edf.screen.ypix_per_deg*ones(nsamp,1);

[edf.samples.x_deg,edf.samples.y_deg] = pix2ang(edf.samples.x,edf.samples.y,edf);

edf.screen.xlim = edf.screen.xres/edf.samples.pix_per_deg_x(1);
edf.screen.ylim = edf.screen.yres/edf.samples.pix_per_deg_y(1);

%% ------------------------------------------------ synthetic EyeLink events
% Blink events, as the EyeLink online parser would report them. Blink
% detection methods 1 and 2 read these.
edf.default_events.Eblink.start = time(blink_onsets)';
edf.default_events.Eblink.end   = time(blink_onsets + round(0.120*sample_rate))';

% Trial start/end events
trial_srt = ((0:ntrial-1)*nsamp_trial + 1)';
trial_end = ((1:ntrial)*nsamp_trial)';
edf.default_events.Start.time = time(trial_srt)';
edf.default_events.End.time   = time(trial_end)';

edf.trial.ind_srt = trial_srt';
edf.trial.ind_end = trial_end';
edf.samples.trial = zeros(nsamp,1);
for tr = 1:ntrial
    edf.samples.trial(trial_srt(tr):trial_end(tr)) = tr;
end

% Trial messages. detect_epoch requires each string in set.msg to appear
% exactly once per trial, in temporal order.
set.msg = {'TRIALID','FixSrt','TarSrt','SacSrt','TrialEnd'};
msg_offsets = [0 0 1.0 1.2 trial_dur-1/sample_rate];   % seconds into trial

info = {}; mtime = [];
for tr = 1:ntrial
    for m = 1:numel(set.msg)
        info{end+1,1} = sprintf('%s %d',set.msg{m},tr);           %#ok<AGROW>
        mtime(end+1,1) = time((tr-1)*nsamp_trial + 1) + ...
                         msg_offsets(m)*1000;                     %#ok<AGROW>
    end
end
edf.default_events.Messages.info = info;
edf.default_events.Messages.time = mtime;

% Pre-compute the fields that detect_epoch would produce, so the GUI can
% open on synthetic data without running the full pipeline first.
nmsg = numel(set.msg);
edf.samples.msg = zeros(nsamp,1);
edf.events.msg.ind_srt = zeros(ntrial, nmsg);
edf.events.msg.ind_end = zeros(ntrial, nmsg);
edf.events.msg.time    = zeros(ntrial, nmsg);

for tr = 1:ntrial
    base = (tr-1)*nsamp_trial;
    for m = 1:nmsg
        s = base + max(1, round(msg_offsets(m)*sample_rate));
        if m < nmsg
            e = base + round(msg_offsets(m+1)*sample_rate) - 1;
        else
            e = base + nsamp_trial;
        end
        edf.events.msg.ind_srt(tr,m) = s;
        edf.events.msg.ind_end(tr,m) = e;
        edf.events.msg.time(tr,m)    = time(s);
        edf.samples.msg(s:e) = m;
    end
end
edf.events.msg.txt = set.msg;

%% -------------------------------------------------------- analysis settings
% Same parameters as demo/data1/setting.m, kept here so the demo is
% self-contained.
set.sac.vel_threshold = 30;        % deg/s
set.sac.acc_threshold = 8000;      % deg/s^2
set.sac.amp_threshold = 0.25;      % deg
set.sac.dur_threshold = 8;         % ms

set.noise.blink_method = 2;        % EyeLink blinks, padded
set.noise.blink_extend = 100;      % ms padding either side
set.noise.gaze_vel     = 1000;     % deg/s
set.noise.gaze_acc     = 100000;   % deg/s^2
set.noise.pupil_sz     = 5;        % MADs
set.noise.pupil_vel    = 100;      % MADs

set.clean.artifact = 0;            % remove all artifact types
set.clean.dist     = 50;           % merge artifacts closer than 50 ms

set.interp.method = 1;             % linear
set.interp.range  = 50;            % ms either side

set.bcorr.msg         = 2;
set.bcorr.method      = 1;
set.bcorr.base_method = 2;

set.fix.disp_threshold = 1.5;     % deg — dispersion threshold for fixation
set.fix.dur_threshold  = 100;     % ms  — minimum fixation duration
set.fix.vel_threshold  = 30;      % deg/s — velocity threshold for fixation

set.noise.baseline_ratio = 0.5;   % baseline ratio for drift correction

set.screen.xres = edf.screen.xres;
set.screen.yres = edf.screen.yres;

set.plot.trial_srt = 1;
set.plot.trial_end = 5;

%% -------------------------------------------------------------- ground truth
% What the pipeline should recover. run_demo.m checks against these.
edf.truth.n_saccades   = ntrial*2;
edf.truth.n_blinks     = ntrial;
edf.truth.sac_onsets   = sac_onsets;
edf.truth.blink_onsets = blink_onsets;
edf.truth.sac_amp_deg  = sac_amp_deg;

edf.dir.file_dir = pwd;
edf.dir.out_dir  = 'result/';
edf.ID           = 'synthetic';

end
