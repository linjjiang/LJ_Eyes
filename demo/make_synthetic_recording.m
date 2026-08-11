function edf = make_synthetic_recording(seed)
% MAKE_SYNTHETIC_RECORDING  Generate a synthetic eye-tracking recording.
%
% Produces the same 'edf' structure that get_params, get_screen_size and
% load_sample would produce from a real EyeLink .edf file, so the rest of
% the pipeline can run without any participant data and without the Edf2Mat
% MEX build.
%
% Analysis parameters live in a separate setting file (see setting_demo.m).
%
%   edf = make_synthetic_recording()      % default seed
%   edf = make_synthetic_recording(42)    % reproducible
%
% Trial structure (a simplified memory-guided saccade trial):
%   0.00 s  TRIALID    trial marker
%   0.05 s  FixSrt     central fixation
%   1.00 s  TarSrt     peripheral target flashes
%   2.00 s  SacSrt     go cue; the eye saccades to the remembered location
%   3.60 s  TrialEnd   return to centre
%
% What the signal contains, and why:
%   Fixational drift     slow low-frequency wander, ~0.1 deg
%   Tremor               white noise, ~0.004 deg per sample
%   Microsaccades        0.15-0.6 deg, Poisson-timed, often with a return
%   Main-sequence        saccade duration 2.2*amplitude + 21 ms
%   Hypometria           the primary saccade lands at ~90% of the target,
%                        followed by a corrective saccade
%   Glissade             damped post-saccadic oscillation at the landing
%   Blinks               pupil ramps to zero, gaze deflects then goes missing
%   Pupil                slow 1/f fluctuation plus a task-evoked dilation
%
% Amplitudes and noise levels are matched to a 500 Hz EyeLink recording
% (gaze SD ~0.9 deg, sample-to-sample |dx| median 0.003 deg, pupil area
% ~1700 +/- 500, blink duration median ~100 ms).
%
% Ground truth, for use as a smoke test (see run_demo.m):
%   8 trials, 4 s each, 500 Hz
%   2 large saccades per trial (out at the go cue, back at trial end) = 16
%   1 blink per trial = 8
% Microsaccades and corrective saccades are deliberately NOT counted as
% ground truth: whether a detector picks them up depends on its thresholds.
%
% The signal is generated, not recorded. No human subject is involved.

if nargin < 1, seed = 7; end
rng(seed);

%% ------------------------------------------------------------------ setup
fs          = 500;              % Hz
ntrial      = 8;
trial_dur   = 4;                % s
nsamp_trial = trial_dur*fs;
nsamp       = ntrial*nsamp_trial;

edf.record.sample_rate = fs;
edf.record.eye         = 'right';
edf.record.mode        = 'CR';
edf.record.pupil_type  = 'area';

% screen parameters (what get_screen_size(edf,1,67.7,38,30.5,1280,1024) gives)
edf.screen.d    = 67.7;         % viewing distance, cm
edf.screen.w    = 38;           % screen width, cm
edf.screen.h    = 30.5;         % screen height, cm
edf.screen.xres = 1280;
edf.screen.yres = 1024;
edf.screen.xpix_per_deg = tand(1/2)*edf.screen.d*2/edf.screen.w*edf.screen.xres;
edf.screen.ypix_per_deg = tand(1/2)*edf.screen.d*2/edf.screen.h*edf.screen.yres;

time = (0:nsamp-1)'*(1000/fs);  % ms, like EyeLink
xc   = edf.screen.xres/2;
yc   = edf.screen.yres/2;

% event timing within a trial, in seconds
t_trialid = 0.00;
t_fixsrt  = 0.05;
t_tarsrt  = 1.00;
t_sacsrt  = 2.00;
t_return  = 3.20;
t_trend   = 3.60;

tar_ecc     = 12;               % target eccentricity, deg
sac_amp_min = 5;                % a saccade above this is a "large" saccade

%% ------------------------------------------------------- generate samples
x_deg = zeros(nsamp,1);         % gaze, deg from screen centre
y_deg = zeros(nsamp,1);
pupil = zeros(nsamp,1);         % pupil area, EyeLink units

blink_onsets = zeros(ntrial,1);
sac_onsets   = zeros(ntrial,2);
tar_pos      = zeros(ntrial,2);

for tr = 1:ntrial
    off = (tr-1)*nsamp_trial;
    k   = off + (1:nsamp_trial);

    % --- target: eight positions around the clock, one per trial ----------
    ang = (tr-1)*2*pi/ntrial + pi/8;
    tar = tar_ecc*[cos(ang) sin(ang)];
    tar_pos(tr,:) = tar;

    % --- saccade schedule -------------------------------------------------
    % A saccade is {onset sample within the trial, displacement [dx dy]}.
    rt_out = 0.180 + 0.080*rand;            % go-cue reaction time, s
    rt_ret = 0.200 + 0.100*rand;
    i_out  = round((t_sacsrt + rt_out)*fs);
    i_ret  = round((t_return + rt_ret)*fs);

    hypo   = 0.88 + 0.05*rand;              % primary saccade undershoots
    i_corr = i_out + round((0.090 + 0.060*rand)*fs);

    sac_i = [i_out; i_corr; i_ret];         % onset sample within the trial
    sac_d = [hypo*tar; (1-hypo)*tar; -tar]; % displacement, [dx dy] in deg

    sac_onsets(tr,:) = off + [i_out i_ret];

    % --- microsaccades during the two fixation periods --------------------
    % Poisson-timed at ~1.5/s, each usually followed by a return within
    % 150-400 ms, as reported for human fixation.
    quiet = {[round(t_fixsrt*fs)+50, i_out-100], ...
             [i_corr+150, i_ret-100]};
    for q = 1:numel(quiet)
        t_now = quiet{q}(1);
        while true
            t_now = t_now + round(exprnd_local(fs/1.5));
            if t_now > quiet{q}(2), break, end
            amp  = 0.15 + 0.45*rand;
            th   = 2*pi*rand;
            d    = amp*[cos(th) sin(th)];
            sac_i(end+1,1) = t_now;  sac_d(end+1,:) = d;           %#ok<AGROW>
            if rand < 0.7                                          % return
                t_back = t_now + round((0.15 + 0.25*rand)*fs);
                if t_back < quiet{q}(2)
                    sac_i(end+1,1) = t_back; sac_d(end+1,:) = -0.8*d; %#ok<AGROW>
                end
            end
        end
    end

    [sac_i,ord] = sort(sac_i); sac_d = sac_d(ord,:);

    % --- integrate the saccades into a position trace ---------------------
    pos = zeros(nsamp_trial,2);
    cur = [0 0];
    for s = 1:numel(sac_i)
        d   = sac_d(s,:);
        A   = norm(d);
        dur = max(4, round((2.2*A + 21)/1000*fs));   % main sequence
        i0  = sac_i(s);
        if i0 < 1 || i0 >= nsamp_trial, continue, end
        i1  = min(i0 + dur, nsamp_trial);

        tau  = linspace(0,1,i1-i0+1)';
        prof = 10*tau.^3 - 15*tau.^4 + 6*tau.^5;     % minimum jerk
        pos(i0:i1,:) = repmat(cur,i1-i0+1,1) + prof*d;
        cur = cur + d;
        pos(i1+1:end,1) = cur(1);
        pos(i1+1:end,2) = cur(2);

        % glissade: damped oscillation along the saccade direction
        gn = round(0.040*fs);
        j1 = min(i1+gn, nsamp_trial);
        if j1 > i1 && A > 0.5
            gamp = min(0.3, 0.05*A);
            tg   = (0:j1-i1-1)'/fs;
            g    = gamp*exp(-tg/0.015).*sin(2*pi*25*tg);
            pos(i1+1:j1,:) = pos(i1+1:j1,:) + g*(d/A);
        end
    end

    % --- fixational drift and tremor --------------------------------------
    % Drift: AR(1)-smoothed noise, low frequency, ~0.1 deg.
    % Tremor: white, matched to the real recording's sample-to-sample step.
    a = 0.999;
    drift = filter(1-a, [1 -a], randn(nsamp_trial,2));
    drift = 0.10*drift./max(std(drift),eps);
    pos = pos + drift + 0.004*randn(nsamp_trial,2);

    x_deg(k) = pos(:,1);
    y_deg(k) = pos(:,2);

    % --- pupil: slow fluctuation plus a task-evoked dilation --------------
    b = 0.9995;
    slow = filter(1-b, [1 -b], randn(nsamp_trial,1));
    slow = 250*slow/max(std(slow),eps);

    tg   = ((1:nsamp_trial)' - t_tarsrt*fs)/fs;
    evk  = zeros(nsamp_trial,1);
    ok   = tg > 0;
    evk(ok) = 200*(tg(ok)/0.9).^2.*exp(-tg(ok)/0.9);   % gamma-shaped

    pupil(k) = 1700 + slow + evk + 15*randn(nsamp_trial,1);

    % --- one blink per trial, at a jittered time --------------------------
    b0 = off + round((0.30 + 0.50*rand)*fs);
    blink_onsets(tr) = b0;
end

%% -------------------------------------------------------- apply the blinks
% An EyeLink blink is not a clean gap. The pupil shrinks as the lid comes
% down, data is lost while the lid covers the pupil, and the gaze deflects
% downward on the way in and out. Missing samples are coded as 0, which is
% what detect_artifact checks for.
blink_dur = zeros(ntrial,1);
for tr = 1:ntrial
    b0   = blink_onsets(tr);
    core = round((0.060 + 0.080*rand)*fs);      % lid fully closed
    ramp = round(0.030*fs);                     % lid opening/closing
    blink_dur(tr) = (core + 2*ramp)/fs*1000;    % ms, for the Eblink event

    i_in  = b0 - ramp : b0 - 1;                 % closing
    i_core= b0 : b0 + core - 1;
    i_out = b0 + core : b0 + core + ramp - 1;   % opening
    i_in  = i_in(i_in >= 1);
    i_out = i_out(i_out <= nsamp);

    % lid artifact: gaze pulled downward, pupil area collapsing
    w_in  = linspace(0,1,numel(i_in))';
    w_out = linspace(1,0,numel(i_out))';
    y_deg(i_in)  = y_deg(i_in)  - 3*w_in;
    y_deg(i_out) = y_deg(i_out) - 3*w_out;
    pupil(i_in)  = pupil(i_in).*(1-w_in);
    pupil(i_out) = pupil(i_out).*(1-w_out);

    % data lost while the lid covers the pupil
    x_deg(i_core) = 0;
    y_deg(i_core) = 0;
    pupil(i_core) = 0;
end

%% ----------------------------------------- pack into the 'edf' structure
% Two columns: column 1 = left eye (not recorded), column 2 = right eye.
% -32768 is the EyeLink sentinel for "no data", which is what the toolbox
% checks for elsewhere.
dead = -32768*ones(nsamp,1);

x_pix = xc + x_deg*edf.screen.xpix_per_deg;
y_pix = yc + y_deg*edf.screen.ypix_per_deg;

% blink core is missing, not a gaze position
missing = pupil == 0;
x_pix(missing) = 0;
y_pix(missing) = 0;

edf.samples.time       = time;
edf.samples.x          = [dead x_pix];
edf.samples.y          = [dead y_pix];
edf.samples.pupil_size = [dead pupil];
edf.samples.ntrial     = ntrial;

edf.samples.pix_per_deg_x = edf.screen.xpix_per_deg*ones(nsamp,1);
edf.samples.pix_per_deg_y = edf.screen.ypix_per_deg*ones(nsamp,1);

[edf.samples.x_deg,edf.samples.y_deg] = pix2ang(edf.samples.x,edf.samples.y,edf);

edf.screen.xlim = edf.screen.xres/edf.samples.pix_per_deg_x(1);
edf.screen.ylim = edf.screen.yres/edf.samples.pix_per_deg_y(1);

%% ------------------------------------------------ synthetic EyeLink events
% EyeLink returns event fields as ROW vectors. detect_epoch reshapes
% Messages.time, so the orientation matters.
edf.default_events.Eblink.start = time(blink_onsets)';
edf.default_events.Eblink.end   = (time(blink_onsets) + blink_dur)';

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

% Trial messages. detect_epoch requires each string in the setting file's
% set.msg to appear exactly once per trial, in temporal order. These must
% match the messages listed in setting_demo.m.
msg_names   = {'TRIALID','FixSrt','TarSrt','SacSrt','TrialEnd'};
msg_offsets = [t_trialid t_fixsrt t_tarsrt t_sacsrt t_trend];

info = {}; mtime = [];
for tr = 1:ntrial
    for m = 1:numel(msg_names)
        info{1,end+1}  = sprintf('%s %d',msg_names{m},tr);         %#ok<AGROW>
        mtime(1,end+1) = time((tr-1)*nsamp_trial + 1) + ...
                         msg_offsets(m)*1000;                      %#ok<AGROW>
    end
end
edf.default_events.Messages.info = info;    % 1 x N, like EyeLink
edf.default_events.Messages.time = mtime;   % 1 x N, like EyeLink

% edf.samples.msg and edf.events.msg are produced by detect_epoch.

%% -------------------------------------------------------------- ground truth
% What the pipeline should recover. run_demo.m checks against these.
% Only the two large saccades per trial are ground truth; microsaccades and
% corrective saccades are threshold-dependent by nature.
edf.truth.n_saccades   = ntrial*2;
edf.truth.n_blinks     = ntrial;
edf.truth.sac_onsets   = sac_onsets;
edf.truth.blink_onsets = blink_onsets;
edf.truth.sac_amp_deg  = tar_ecc;
edf.truth.sac_amp_min  = sac_amp_min;
edf.truth.tar_pos      = tar_pos;

edf.dir.file_dir = pwd;
edf.dir.out_dir  = 'result/';
edf.ID           = 'synthetic';

end

% -------------------------------------------------------------------------
function s = exprnd_local(mu)
% Exponential sample, so no Statistics Toolbox is required.
s = -mu*log(rand);
end
