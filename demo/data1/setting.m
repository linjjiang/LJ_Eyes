function set = setting()
% settings for eye-tracking analysis
% please change the value directly below based on your analysis preferences

%% The sequence of the messages within a trial %jen-what is f and H
set.msg = {'Trial No',...
'Starting - Fixation cross',...
'Starting - Stimuli',...
'Starting - F + H Screen ',...
'Starting - F or H Response Screen',...
'Starting Recording Confidence Ratings',...
'Starting Confidence Ratings Response'};
% In the following analysis, each of these messages will be marked as from
% 1 to n

%% Which eye to analyze
% 1. left
% 2. right
% 3. binocular
set.eye = 2; 

%% Saccade and fixation detection methods
% % Nystrom's detection algorithm
% % minimum saccade duration
% set.sac.min_dur = 0.15; % 150 ms
% 
% % initial peak velocity threshold
% set.sac.init_velpeak_threshold = 100; % Initial value of the peak detection threshold. 
% 
% % minimum fixation duration
% set.fix.min_dur = 0.030; % in seconds
% 
% % blink velocity threshold
% set.blink.vel_threshold = 1000; % if vel > 1000 degrees/s, it is noise or blinks
% 
% % blink acceleration threshold
% set.blink.acc_threshold = 100000; % if acc > 100000 degrees/s^2, it is noise or blinks

% Velocity-based saccade detection
% Saccades were identified by identifying periods with velocity in excess 
% of 30°/s and acceleration in excess of 8000°/s^2 for at least 8 ms and 
% resulting in at least a 0.25° amplitude gaze shift.
set.sac.vel_threshold = 30; %threshold velocity for saccades (deg/s)
set.sac.acc_threshold = 8000; %threshold acceleration for saccades (deg/s^2)
set.sac.amp_threshold = 0.25; %threshold amplitude for saccades (deg)
set.sac.dur_threshold = 8; % duration threshold for saccades (ms)

%% Blink detection methods

% set.blink.methods
% methods of performing blink detection

% 1. default blink detection from eyelink
% Definition: a period of saccade detector activity with the pupil data 
% missing for three or more samples in a sequence

% 2. default blink detection from eyelink with extension of time window
% set.blink.extend: the time window extended before and after the blink (in
% ms)

% 3. velocity algorithm by Mathot (2013)

% 4. noise-based algorithm by Hershman et al. (2018)

set.noise.blink_method = 2; 
set.noise.blink_extend = 100; % 100 ms before and after detected blink. change this if you use method 2.
set.noise.gaze_vel = 1000; % if gaze velocity > 1000 degrees/s, it is noise or blinks
set.noise.gaze_acc = 100000; % if gaze acceleration > 100000 degrees/s^2, it is noise or blinks
set.noise.pupil_sz = 5; % how many median absolute deviations of pupil size
set.noise.pupil_vel = 100; % how many median absolute deviations for pupil velocity

%set.extreme_pupil.lamda = 3; % how many median absolute deviations for pupil size
%set.extreme_pupil_vel.lamda = 100; % how many median absolute deviations for pupil change speed
%set.extreme_pupil.threshold = 1000;             
%ETparams.blinkAccThreshold = 100000;               

%% Data cleaning options
set.clean.artifact = 0; % choose which type of artifact to remove from the data
% 0: all artifacts
% 1: blinks
% 2: missing data
% 3. gaze data outside of the screen boundary
% 4. extreme velocity and acceleration of the gaze
% 5. extreme size of the pupil
% 6. extreme velocity of the pupil

set.clean.dist = 50; % if two artifacts are 50 ms within each other, then merge these two 
%% Interpolation (for pupil data)
set.interp.method = 1; 
% 1: linear interpolation
% 2: spine interpolation

set.interp.range = 50; % Interpolation based on how many ms samples prior and after

%% Baseline correction (for pupil data)
set.bcorr.msg = 2; % choose the period between the 2nd and the 3rd message as the baseline period
% In this scenario, it is the fixation period

% choose the method of baseline correction
set.bcorr.method = 1; % 1, substractive; 2, divisive

% choose how to calculate the baseline pupil value, by taking either mean
% or median of the baseline period throughout the task
set.bcorr.base_method = 2; % 1, mean; 2, median of the baseline values

%% Which trial to plot %jen why is it 5?
set.plot.trial_srt = 1; % start trial of plotting
set.plot.trial_end = 5; % end trial of plotting

end

