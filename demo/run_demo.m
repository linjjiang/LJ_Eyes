%% LJ_Eyes demo: preprocess a synthetic recording end to end
%
% Generates a synthetic recording with known saccades and blinks, runs the
% full pipeline, checks the detectors against ground truth, and opens the
% GUI for visual inspection.
%
% No participant data and no Edf2Mat MEX build required.
%
% Run from the repo root:
%   addpath(genpath(pwd))
%   run_demo
%
% To process a real .edf instead, replace section 1 with:
%   edf1 = edf2mat(file_dir,out_dir);
%   set  = setting_yourexp();          % copy setting_demo.m → setting_yourexp.m
%   edf  = get_params(edf1);
%   edf  = get_screen_size(edf,1,60,37.7,30.2,1024,768);
%   edf  = load_sample(edf1,edf,set,file_dir,out_dir);
% and continue from section 2 unchanged.

clear; close all; clc

%% 1. Generate the recording and load settings ------------------------------
edf = make_synthetic_recording(7);
set = setting_demo();

fprintf('Synthetic recording: %d trials, %d samples at %d Hz\n', ...
    edf.samples.ntrial, size(edf.samples.time,1), edf.record.sample_rate);
fprintf('Injected: %d saccades, %d blinks\n\n', ...
    edf.truth.n_saccades, edf.truth.n_blinks);

%% 2. Smoothing -------------------------------------------------------------
edf = sgolay_smoothing(edf,set);

%% 3. Velocity and acceleration ---------------------------------------------
edf = cal_velacc(edf,set);

%% 4. Artifact detection ----------------------------------------------------
edf = detect_artifact(edf,set);

fprintf('Blinks detected:      %d  (injected %d)\n', ...
    edf.blink.num, edf.truth.n_blinks);
fprintf('Samples flagged:      %.2f%%\n\n', 100*edf.trackloss.perc);

%% 5. Artifact removal ------------------------------------------------------
edf = remove_artifact(edf,set);

%% 6. Event segmentation ----------------------------------------------------
edf = detect_epoch(edf,set);

%% 7. Saccade and fixation detection ----------------------------------------
edf = detect_saccades(edf,set);
edf = detect_fixations(edf,set);

% The recording also contains microsaccades and corrective saccades, so
% compare only the large task saccades against ground truth.
big  = edf.events.sac.amp > edf.truth.sac_amp_min;
nsac = sum(big);
nfix = numel(edf.events.fix.trial);
fprintf('Saccades detected:    %d total, %d large  (injected %d large)\n', ...
    numel(edf.events.sac.amp), nsac, edf.truth.n_saccades);
fprintf('Fixations detected:   %d\n', nfix);
if nsac > 0
    fprintf('Median amplitude:     %.1f deg  (target at %.1f)\n', ...
        median(edf.events.sac.amp(big)), edf.truth.sac_amp_deg);
    fprintf('Median peak velocity: %.0f deg/s\n\n', ...
        median(edf.events.sac.peak_vel(big)));
end

%% 8. Drift correction ------------------------------------------------------
edf = drift_correction(edf,set);
edf = load_sample_after_dc(edf,set);

% Re-detect on drift-corrected signal
edf = detect_saccades_after_dc(edf,set);
edf = detect_fixations_after_dc(edf,set);

% Merge saccades split by noise and compute endpoints
edf = combine_saccades(edf,set);
edf = cal_saccades_endpoint(edf,set);

%% 9. Check the detectors against ground truth ------------------------------
% Deliberately loose: detectors legitimately split or merge events near
% threshold. These bounds catch a broken pipeline, not a slightly tuned one.
ok = true;

if edf.blink.num ~= edf.truth.n_blinks
    fprintf(2,'FAIL: expected %d blinks, got %d\n', ...
        edf.truth.n_blinks, edf.blink.num); ok = false;
end

if nsac < edf.truth.n_saccades*0.8 || nsac > edf.truth.n_saccades*1.5
    fprintf(2,'FAIL: expected ~%d large saccades, got %d\n', ...
        edf.truth.n_saccades, nsac); ok = false;
end

if nsac > 0
    amp_err = abs(median(edf.events.sac.amp(big)) - edf.truth.sac_amp_deg);
    if amp_err > 2
        fprintf(2,'FAIL: median amplitude off by %.1f deg\n', amp_err); ok = false;
    end
end

if ok
    fprintf('All checks passed.\n');
else
    fprintf(2,'Some checks failed - see above.\n');
end

%% 10. View in GUI ----------------------------------------------------------
miniEye_ver0;
