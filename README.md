# LJ_Eyes

A MATLAB toolbox for preprocessing eye-tracking recordings from SR Research EyeLink
trackers: blink and artifact removal, drift correction, and saccade/fixation detection.
It is for researchers and analysts who have `.edf` recordings and need cleaned samples and
labelled events out the other end. Analyses are run from scripts; a small GUI is included
for inspecting recordings by eye. It replaced a manual, per-recording workflow in our lab
and cut preprocessing time per session by roughly 10–20×.

Requires MATLAB R2019b or newer. Processing your own data additionally requires
[Edf2Mat](https://github.com/uzh/edf-converter) for `.edf` import; the demo below does not.

## Quickstart

```matlab
addpath(genpath(pwd))   % from the repo root
run_demo                % generate a synthetic recording, preprocess it, check the output
```

`run_demo` builds a recording with known saccades and blinks, runs the full pipeline, and
reports whether the detectors recovered what was injected:

```
Synthetic recording: 8 trials, 16000 samples at 500 Hz
Injected: 16 saccades, 8 blinks

Blinks detected:      8  (injected 8)
Samples flagged:      6.41%
Saccades detected:    16  (injected 16)
Median amplitude:     11.9 deg  (injected 12.0)
```

No participant data ships with this repository, by design. `make_synthetic_recording.m`
generates its input, so the demo doubles as a smoke test: it has ground truth, so a
regression in the detectors shows up as a failed check rather than a plot that looks
plausible.

To run the pipeline on a real recording, replace section 1 of `run_demo.m` with the
`edf2mat` / `get_params` / `load_sample` calls documented at the top of that file. Every
analysis parameter lives in the settings struct; no thresholds are set inside the
processing functions.

## Inspecting a recording

`myGUI_miniEye/miniEye_ver0.mlapp` plots one trial at a time. You can step through trials,
switch the y-axis between pupil and gaze channels, compare raw against cleaned samples,
scrub a time window, and toggle overlays for detected fixations, saccades, and trial
messages. It is a viewer only — it does not run or modify the pipeline, and detected
events cannot be edited from it.

## What it does

**Import** — reads `.edf` via Edf2Mat and pulls out sampling rate, recorded eye, screen
geometry, and the calibration/validation results. Converts between pixels and degrees of
visual angle, and computes gaze velocity and acceleration with a five-sample differentiator
(Engbert & Kliegl).

**Artifact detection** — flags samples as missing pupil, gaze outside the screen bounds,
extreme gaze velocity/acceleration, extreme pupil size, or extreme pupil velocity, the last
two in median-absolute-deviation units. Artifacts closer than a configurable gap are
merged. Reports per-recording track-loss percentage and blink count.

**Blink detection** — four selectable methods: the EyeLink parser's own blink events; those
events padded by a configurable window; a velocity-based method (Mathôt, 2013); and a
noise-based method (Hershman et al., 2018).

**Cleaning** — removes flagged samples, then optionally linear or spline interpolation
across gaps, Savitzky–Golay smoothing, and pupil baseline correction (subtractive or
divisive, against the mean or median of a baseline epoch).

**Drift correction** — estimates and removes slow gaze drift, with saccade and fixation
detection re-run on the corrected signal.

**Event detection** — segments trials and task epochs from EyeLink messages, then detects
saccades using joint velocity, acceleration, amplitude, and duration thresholds, and
detects fixations. Computes saccade endpoints and merges saccades split by noise. Helpers
select the primary saccade per trial.

**Plotting** — raw and cleaned time courses, artifact distributions, and gaze-on-screen
plots.

## Layout

```
data_import/        .edf import, recording and screen parameters, calibration
data_cleaning/      artifact detection, removal, interpolation, smoothing, drift correction
blink_analysis/     the four blink detection methods
event_detection/    trial/epoch segmentation, saccade and fixation detection
event_selection/    per-trial selection of saccades of interest
plot/               figure generation
myGUI_miniEye/      the inspection GUI
general_functions/  unit conversion and shared helpers
external_functions/ vendored third-party code (own licenses)
demo/               synthetic recording generator and the demo script
```

## Status and limitations

Research code, written for my own and my labmates' use. Scope worth knowing before you
adopt it:

- Trial and epoch segmentation is driven by the message strings in the settings struct,
  which are experiment-specific. Applying the toolbox to a new paradigm means editing that
  list, and possibly the event-selection step.
- Only monocular analysis is exercised. The binocular option is present but untested.
- `run_demo` is the only automated check; there is no unit test suite.
- `blink_analysis/blink_Nystrom.m` is an unfinished port and is not wired into the pipeline.
- No participant data is distributed with this repository and none will be. If you need to
  validate against a real recording, use your own.

## License

BSD 3-Clause — see [LICENSE](LICENSE). Vendored code under `external_functions/` and parts
of `general_functions/` carries its own licenses.

## Credits

[Edf2Mat](https://github.com/uzh/edf-converter) (UZH) for `.edf` reading. Blink detection
after Mathôt (2013) and Hershman, Henik & Cohen (2018). Velocity/acceleration after Engbert
& Kliegl (2003).
