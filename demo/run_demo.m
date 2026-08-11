%% LJ_Eyes demo: preprocess a synthetic recording end to end
%
% Generates a synthetic recording with known saccades and blinks, runs the
% full pipeline (artifact detection, cleaning, interpolation, smoothing,
% epoch segmentation, saccade/fixation detection, drift correction, and
% baseline correction), checks the detectors against ground truth, and
% opens the GUI for visual inspection.
%
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

%% 5. Interpolation ---------------------------------------------------------
edf = do_interpolation(edf,set);

%% 6. Smoothing -------------------------------------------------------------
edf = sgolay_smoothing(edf,set);

%% 7. Event segmentation ----------------------------------------------------
edf = detect_epoch(edf,set);

%% 8. Baseline correction ---------------------------------------------------
edf = baseline_correction(edf,set);

%% 9. Saccade and fixation detection ----------------------------------------
edf = detect_saccades(edf,set);
edf = detect_fixations(edf,set);

nsac = numel(edf.events.sac.trial);
nfix = numel(edf.events.fix.trial);
fprintf('Saccades detected:    %d  (injected %d)\n', nsac, edf.truth.n_saccades);
fprintf('Fixations detected:   %d\n', nfix);
if nsac > 0
    fprintf('Median amplitude:     %.1f deg  (injected %.1f)\n', ...
        median(edf.events.sac.amp), edf.truth.sac_amp_deg);
    fprintf('Median peak velocity: %.0f deg/s\n\n', median(edf.events.sac.peak_vel));
end

%% 10. Drift correction -----------------------------------------------------
edf = drift_correction(edf,set);

% Re-run detection on drift-corrected signal
edf = detect_saccades_after_dc(edf,set);
edf = detect_fixations_after_dc(edf,set);

%% 11. Check the detectors against ground truth -----------------------------
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

%% 12. View in GUI ----------------------------------------------------------
miniEye_ver0;
