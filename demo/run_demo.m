%% LJ_Eyes demo: preprocess a synthetic recording end to end
%
% Generates a synthetic recording with known saccades and blinks, runs it
% through the pipeline, and checks that the detectors recover what was put in.
% No participant data and no Edf2Mat MEX build required.
%
% Run from the repo root:
%   addpath(genpath(pwd))
%   run_demo
%
% To process a real .edf instead, replace section 1 with:
%   edf1 = edf2mat(file_dir,out_dir);
%   set  = setting();
%   edf  = get_params(edf1);
%   edf  = get_screen_size(edf,1,60,37.7,30.2,1024,768);
%   edf  = load_sample(edf1,edf,set,file_dir,out_dir);
% and continue from section 2 unchanged.

clear; close all; clc

%% 1. Generate the recording -----------------------------------------------
[edf,set] = make_synthetic_recording(7);

fprintf('Synthetic recording: %d trials, %d samples at %d Hz\n', ...
    edf.samples.ntrial, size(edf.samples.time,1), edf.record.sample_rate);
fprintf('Injected: %d saccades, %d blinks\n\n', ...
    edf.truth.n_saccades, edf.truth.n_blinks);

%% 2. Velocity and acceleration --------------------------------------------
edf = cal_velacc(edf,set);

%% 3. Artifact detection ----------------------------------------------------
edf = detect_artifact(edf,set);

fprintf('Blinks detected:      %d  (injected %d)\n', ...
    edf.blink.num, edf.truth.n_blinks);
fprintf('Samples flagged:      %.2f%%\n\n', 100*edf.trackloss.perc);

%% 4. Artifact removal ------------------------------------------------------
edf = remove_artifact(edf,set);

%% 5. Event segmentation ----------------------------------------------------
edf = detect_epoch(edf,set);
edf = detect_saccades(edf,set);

nsac = numel(edf.events.sac.trial);
fprintf('Saccades detected:    %d  (injected %d)\n', nsac, edf.truth.n_saccades);
if nsac > 0
    fprintf('Median amplitude:     %.1f deg  (injected %.1f)\n', ...
        median(edf.events.sac.amp), edf.truth.sac_amp_deg);
    fprintf('Median peak velocity: %.0f deg/s\n\n', median(edf.events.sac.peak_vel));
end

%% 6. Check the detectors against ground truth ------------------------------
% Deliberately loose: detectors legitimately split or merge events near
% threshold. These bounds catch a broken pipeline, not a slightly tuned one.
ok = true;

if edf.blink.num ~= edf.truth.n_blinks
    fprintf(2,'FAIL: expected %d blinks, got %d\n', ...
        edf.truth.n_blinks, edf.blink.num); ok = false;
end

if nsac < edf.truth.n_saccades*0.8 || nsac > edf.truth.n_saccades*1.5
    fprintf(2,'FAIL: expected ~%d saccades, got %d\n', ...
        edf.truth.n_saccades, nsac); ok = false;
end

if nsac > 0
    amp_err = abs(median(edf.events.sac.amp) - edf.truth.sac_amp_deg);
    if amp_err > 2
        fprintf(2,'FAIL: median amplitude off by %.1f deg\n', amp_err); ok = false;
    end
end

if ok
    fprintf('All checks passed.\n');
else
    fprintf(2,'Some checks failed - see above.\n');
end

%% 7. View in GUI ----------------------------------------------------------
% The GUI reads cleaned/drift-corrected fields that the demo pipeline does
% not produce (it stops after detection). Copy the raw signals into those
% slots so the GUI can launch; all display modes will show the same data.
if ~isfield(edf.samples,'x_deg_clean')
    edf.samples.x_deg_clean       = edf.samples.x_deg;
    edf.samples.y_deg_clean       = edf.samples.y_deg;
    edf.samples.pupil_size_clean  = edf.samples.pupil_size;
end
if ~isfield(edf.samples,'x_deg_clean_drift')
    edf.samples.x_deg_clean_drift     = edf.samples.x_deg;
    edf.samples.y_deg_clean_drift     = edf.samples.y_deg;
    edf.samples.pupil_size_clean_drift = edf.samples.pupil_size;
end
if ~isfield(edf.samples,'pupil_size_corr')
    edf.samples.pupil_size_corr = edf.samples.pupil_size;
end
if ~isfield(edf.events,'fix')
    empty_ev = struct('ind_srt',[],'ind_end',[],'trial',[]);
    edf.events.fix    = empty_ev;
    edf.events.sac_dc = empty_ev;
    edf.events.fix_dc = empty_ev;
end

miniEye_ver0;