%% Demo script: how to use this eye-tracking toolbox

% By: Linjing Jiang
% VerDate: 06/2021
% Contact: linjing.jiang@stonybrook.edu

%% Step 1: File Conversion (Edfmex conversion toolbox)
% The first step is to import the edf file into MATLAB, using the
% Edf2Mat toolbox
% toolbox

% Clean the workspace and everything
clear all
close all
clc

% Set up the data directory, where you store all your data,
% e.g., 'D:/linjing_eyetracking/test'
data_dir = 'C:\Users\lj104\Documents\Linjing_Research\EyeAnalysis\LJ_Eyes-main\LJ_Eyes-main\test_data\';

% Set up any subfolder under top_dir indicating different subjects or
% recording sessions, e.g.,'1000/'
% Make sure that there is a single edf file under this folder
file_dir = ''; % Here we do not have a subfolder
addpath(genpath([data_dir file_dir]))

% Set up the script directory, where you store the scripts
script_dir = 'C:\Users\lj104\Documents\Linjing_Research\EyeAnalysis\LJ_Eyes-main\LJ_Eyes-main\';
addpath(genpath(script_dir))

% Set up the output folder UNDER data_dir
out_dir = 'result/'; % In this case, the output will appear in data_dir + out_dir

% Import the .edf file
edf1 = edf2mat(data_dir,file_dir,out_dir);

% After you've done this, you will go into the specific data folder with
% the edf file. At the same time, in the Workspace you will see a "EDF2MAT"
% object which contains all the eye data imported from the edf file

% Check the manual of EDF2MAT if you are interested in what variables of
% the "EDF2MAT" object mean

%% Step 2 Set up parameters and load eye data from the EDF2MAT object

% Set up all the analysis parameters using the "setting" script
% A script called "setting" will automatically open. Please change the
% analysis parameters directly in the "setting" script. After you finalize
% the change, close the script, click the command window and press any key
% to proceed.
open setting
pause
set = setting();

% Get basic recording parameters from the edf file: sampling rate, pupil type,
% record type, eye recorded
% Note that here we created a new structure called 'edf' for the first time and
% load some recording parameters from 'edf1' (the EDF2MAT object) to 'edf'
edf = get_params(edf1);

% Set up screen parameters
% Note that there are 7 inputs to the 'get_screen_size' function, including
% 'edf': stored eye data structure (Please don't change this!!!)
% '1' (use customized parameters) or '0' (use default screen parameters).
% If you use customed parameters, please enter the following in sequence:
% distance from the eyes to the screen (in cm)
% width (in cm), height (in cm), x resolution (in pixel), y resolution 
% (in pixel) of the monitor
edf = get_screen_size(edf,1,60,37.7,30.2,1024,768); 

% Then, we extract important eye data from the EDF2MAT object and copy
% them to 'edf'
edf = load_sample(edf1,edf,set);

% Calculate velocity and acceleration
edf = cal_velacc(edf,set);

% Finally, we get calibration results from 'edf1' to 'edf' using the
% "get_calib" function
edf = get_calib(edf1,edf);

% All done! Now save the raw data to a .mat file
fprintf('\n');
fprintf('saving .mat file...');

cd([data_dir,file_dir]) % make sure you entered the data folder
edf_file = dir('*.edf');
filename = erase(edf_file.name,'.edf'); edf.ID = filename;
save([out_dir,filename,'_step2']);

% Inspect the raw data
% In eye-tracking analysis, it is important to check the raw data all the
% time
miniEye_ver0;

%% Step 3 Artifact detection
% Next, let's detect artifacts in the data. This step would yield
% "edf.trackloss", under which there are multiple fields:
% 1. 'blink_ind': index for detected blinks
% 2. 'missing_ind': index for missing data (including blinks)
% 3. 'outside_ind': index for gaze position out of the screen boundary
% (either horizontal or vertical)
% 4. 'ext_ind': Extremely large sizes of pupil
% 5. 'pvel_ind': Extremely large velocity of pupil
% 6. 'all_ind': a combination of all the artifacts above
% 7. 'perc': percentage of artifacts overall
% You can set up the definition of most of those artifacts in the setting
% script
% Also note that all these indexes are based on the 'edf.samples'. For
% instance, an index of 300 indicates the 300th. row (sample) in any of the
% edf.samples array

% Detect artifacts
edf = detect_artifact(edf,set);

% Plot artifacts (will generate and save data figures automatically in the
% output folder)
plot_artifact(edf,data_dir,file_dir,out_dir,set);

% Output trackloss data (will generate a .csv file containing all the
% trackloss data)
tbl = table(edf.trackloss.perc,edf.blink.num,'VariableNames',{'Percentage of sample with artifacts','Number of blinks'});
writetable(tbl,[data_dir,file_dir,out_dir,'trackloss_id',edf.ID,'.csv']);
clear tbl

% save the data
clearvars edf1 edf_file
fprintf('\n');
fprintf('saving .mat file...');
save([data_dir,file_dir,out_dir,filename,'_step3']);

% Now, you should visually inspect blinks (optional if you are analyzing gaze locations)
% If you are doing blink analysis, this step is a MUST
% You should manually check all the blinks and see if those are truly
% blinks, not other types of artifacts
miniEye_ver0;
% However, at this point, you can only inspect the blinks (its onset and
% offset) without manually editing it. In the future I will add more
% editing function to the GUI so that you can modify the blink events
% directly using the toolbox

%% Step 4 Data Cleaning

close all

% Then, we need to remove artifacts from both the gaze and the pupil data
edf = remove_artifact(edf,set);

% Plot the time courses after artifact removal(automatically generate
% figures)
plot_timecourse_clean(edf,data_dir,file_dir,out_dir,set);
% Alternatively, you can also inspect the data with our GUI
miniEye_ver0;

% IF YOU ARE ANALYZING PUPIL SIZE:
% Do spatial interpolation of the pupil data
edf = do_interpolation(edf,set);

% Then do baseline correction if needed
% Here we gave an exmaple of baseline correction for the pupil size
edf = baseline_correction(edf,set);

% Now you can inspect all types of the data again. Compare different plots and see
% what their main differences are!
miniEye_ver0;

% save the data
fprintf('\n');
fprintf('saving .mat file...');
save([data_dir,file_dir,out_dir,filename,'_step4']);

%% Step 5 Event segmentation
% This is specifically for saccade and fixation analysis

% First, we need to detect different trials and task epochs
edf = detect_epoch(edf,set);

% Then, detect saccades in each trial
edf = detect_saccades(edf,set);

% Plot the events
miniEye_ver0;




