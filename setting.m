function set = setting()
% settings for eye-tracking analysis
% please change the value directly below based on your analysis preferences

%% The sequence of the messages within a trial
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

set.blink.methods = 2;
set.blink.extend = 100; % 100 ms before and after detected blink. change this if you use method 2.

set.extreme_pupil.lamda = 3; % how many median absolute deviations for pupil size
set.extreme_pupil_vel.lamda = 100; % how many median absolute deviations for pupil change speed

%% Data cleaning options
set.clean.artifact = 0; % choose which type of artifact to remove from the data
% 0: all artifacts
% 1: only blinks
% 2: only missing data
% 3. only gaze data outside of the screen boundary
% 4. only extreme size of the pupil
% 5. only extreme velocity of the pupil

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

%% Which trial to plot
set.plot.trial_srt = 1; % start trial of plotting
set.plot.trial_end = 5; % end trial of plotting

end

