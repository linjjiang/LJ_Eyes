%% Demo script: how to use this eye-tracking toolbox

% By: Linjing Jiang
% VerDate: 02/2023
% Contact: linjing.jiang@stonybrook.edu

% This script shows how to use my toolbox, LJ_Eyes, to preprocess your
% eye-tracking data. It contains the following steps:
% 0. Preparation
% 1. File conversion: import .edf files (the original format of eye data
% file) to the workspace
% 2. Set up analsis parameters and load up variables of interest from the
% imported eye data
% 3. Artifact detection
% 4. Data cleaning (artifact removal)
% 5. Event segmentation
% 6. Select events of interest

% I highly recommend you to run the script line by line. Check the input
% and output of each line of code to understand what each step does. When
% you check the input and output, think about the following questions:
% 1) What new variables are generated from this step of analysis?
% 2) How many rows and columns does the new variable have? 
% 3) What does each row and column mean?
% Focus on the two main variables I created throughout the analysis:
% edf: a matlab "structure" that contains eye data and calculation
% set: another matlab "structure" that contains analysis preference and
% parameters
% What is a "structure"?

% Note that I packed the analysis into a series of functions to make my code
% more neat and organized. Each function is like a blackbox that contains
% many small steps of analysis - you should not worry about the detailed of
% each function at this point, just focus on understanding what each
% function does in general via checking its input and output. Later on when
% you get more comfortable with the toolbox and want to know what each
% function actually does, you can easily check and even modify the source
% code by right-clicking the name of the function and select "open".

% It's also important to know that this version of script is tailored to a
% specific experiment - memory-guided saccade experiment (MGS). In this
% experiment, we brielfy present a image of a face or a house on the screen
% for 500 msec. After a delay of 8 or 10 sec, participants were asked to move
% their eyes to where the image was as quickly and accurately as possible,
% and look back at the center cross immediately. Eye movements were
% recorded whe participants performed two runs of the MGS task. Each run
% consists of 16 trials, corresponding to the "MGS1" and "MGS2"
% folder under the "tutorial_data" folder. There are two subjects under
% each run folder, "p13_1" and "s20_1".

% Using this task, we are interested in understanding how well a
% participant's spatial working memory is - the ability to maintain and
% manipulate spatial information temporarily to guide behavior. Therefore,
% our analysis focuses on the response period, when participants make eye
% movements to the remembered location, and we use their first big eye
% movement - called primary saccade - to estimate the working memory
% performance. If you are interested in learning more about the specific
% task/analysis, please check my previous paper: https://pubmed.ncbi.nlm.nih.gov/34262103/

% If you are interested in applying the script to other tasks or other
% types of analysis, you might need to modify the script a little bit,
% including: 1) change parameters in the setting function (e.g.,
% tutorial_setting.m); 2) modify some parts of step 5 & 6. If not sure,
% consult Linjing before moving forward. Regardless, this toolbox should be
% able to preprocess a wide range of task and resting-state data.

%% Step 0.0: Data preparation
% Please check if you have tutorial data downloaded.
% You should see a folder called "tutorial_data" under the
% "training_spring2023" folder.

% You must organize the data in the following format (here, I already
% organized it for you):
% run folder (task name + run number) -> subject folder (with edf file)

%% Step 0.1: Install edf2mat toolbox (external toolbox)
% I have already included the edf2mat toolbox under the
% "external_functions" folder. To make it work:
% 1) Add the toolbox to your matlab path
% 2) Additional installation instruction (IMPORTANT!), see:
% https://github.com/uzh/edf-converter

% Run the following command to see if you correctly installed the toolbox:
help Edf2Mat % help function
% Load an example dataset
cd '.\external_functions\edf-converter-master'
edf_test = Edf2Mat('eyedata.edf');

% You should see a description of Edf2Mat function as well as
% "Converting: 100%" in your command window. You should also see a variable
% "edf_test" in your workspace. If not, check the Github installation
% instruction above.

%% Step 1: File Conversion (Edfmex conversion toolbox)
% The first step is to import the edf file into MATLAB, using the
% Edf2Mat toolbox

% Clean the workspace and everything
clear
close all
clc

% Set up the data directory, where you store all your data (Please remember
% to change the directory when you use it!)
% MAKE SURE YOU END THE DIRECTORY WITH A SLASH!!!
data_dir = '.\demo\training_spring2023\tutorial_data\';

% Find all subjects and all sessions under the data directory
% Note that I have two naming systems, so that's why I need to find all
% folders starting with either 'p' or 's'. Usually, if you have the same
% naming system, e.g., all your subjects start with 'ss', you only need one
% of the lines below, e.g., dir[data_dir 'MGS*\ss']
file_dirs1 = dir([data_dir 'MGS*\p*']); % Find all run folders start with "MGS" and under that folder, all subject folders start with "p"
file_dirs2 = dir([data_dir 'MGS*\s*']);  % Find all run folders start with "MGS" and under that folder, all subject folders start with "s"
file_dirs = [file_dirs1;file_dirs2]; % Concatenate all folders

% Set up the script directory, where you store the scripts
script_dir = '.\';

% Add the data and script directory to your path using addpath(genpath(())
addpath(genpath(data_dir))
addpath(genpath(script_dir))

% Set up the output folder
out_dir = 'result\'; % In this case, the output will appear in data_dir + each file directory + out_dir

% Below, I coded a "for" loop to iterate the preprocessing steps across
% subject and run folders. It is an effective strategy to use if you want
% to repeat the same analysis across subjects. But if it is your first time
% using this toolbox, I would recommend that you comment the for loop and
% analyze just one single subject (add a "%" sign before line 116 and
% the final line of the script, and delete the "%" sign before the line
% 117).

for ff = 1:length(file_dirs)
    %ff = 1;
    clearvars -except out_dir data_dir file_dirs ff % clear all the intermediate variables when you repeat the analysis on a different subject
    close all % close all figures
    file_dir = [erase(file_dirs(ff).folder,data_dir) '\' file_dirs(ff).name '\']; % Get the path of the file directory

    % Import the .edf file
    edf1 = edf2mat(data_dir,file_dir,out_dir);

    % Now, you should find yourself inside the specific subject folder with
    % the edf file. Meanwhile,you will see a "EDF2MAT" object in the workspace,
    % which contains the imported edf data.

    % Check the manual of EDF2MAT if you are interested in knowing what 
    % each variable in the "EDF2MAT" object means.

    %% Step 2 Set up parameters and load eye data from the EDF2MAT object

    % Set up all the analysis parameters using the "setting" script.
    % You can (and SHOULD) customize a script called "tutorial_setting",
    % which contains all the key parameters for analysis, especially,
    % 1) edf messages; 2) screen setting
    % What are messages?
    % Why is it important to enter screen settings?

    % You can open the setting script using the following command (remember
    % to comment it after you finalize the change)
    % open tutorial_setting

    % Pass the setting to a variable called "set"
    set = tutorial_setting(edf1);

    % Get basic recording parameters from the edf file: sampling rate, pupil type,
    % record type, eye recorded
    % Note that here we created a new structure called 'edf' for the first time and
    % load some recording parameters from 'edf1' (the EDF2MAT object) to 'edf'
    edf = get_params(edf1);

    % Set up screen parameters
    % Note that there are 7 inputs to the 'get_screen_size' function, including
    % 'edf': stored eye data structure (Please don't change this!!!)
    % '1' (use customized parameters) or '0' (use default screen parameters).
    % If you use customized parameters, please enter the following in sequence:
    % distance from the eyes to the screen (in cm)
    % width (in cm), height (in cm), x resolution (in pixel), y resolution
    % (in pixel) of the monitor
    % Since we already set up these parameters in "set", just pass the set
    % variables to the function
    edf = get_screen_size(edf,1,set.screen.d,set.screen.w,set.screen.h, ...
        set.screen.xres,set.screen.yres);

    % Then, we extract important eye data from the EDF2MAT object and copy
    % them to 'edf'
    edf = load_sample(edf1,edf,set,data_dir,file_dir,out_dir);

    % Calculate velocity and acceleration
    edf = cal_velacc(edf,set);

    % Finally, we get calibration results from 'edf1' to 'edf' using the
    % "get_calib" function
    edf = get_calib(edf1,edf);

    % All done! Now save the raw data to a .mat file
    fprintf('\n');
    fprintf('saving .mat file...');

    cd([data_dir,file_dir]) % enter the data folder
    edf_file = dir('*.edf');
    filename = erase(edf_file.name,'.edf'); edf.ID = filename;
    save([out_dir,filename,'_step2']);

    %% Step 3 Artifact detection
    % Next, let's detect artifacts in the data. This step generates
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

    %% Step 4 Data Cleaning

    close all % close all figures

    % Then, we need to remove artifacts from both the gaze and the pupil data
    edf = remove_artifact(edf,set);

    % Plot the time courses after artifact removal(automatically generate
    % figures)
    plot_timecourse_clean(edf,data_dir,file_dir,out_dir,set);

    % % IF YOU ARE ANALYZING PUPIL SIZE:
    % % Do spatial interpolation of the pupil data
    % edf = do_interpolation(edf,set);

    % % Then do baseline correction if needed
    % % Here we gave an exmaple of baseline correction for the pupil size
    % edf = baseline_correction(edf,set);

    % save the data
    fprintf('\n');
    fprintf('saving .mat file...');
    save([data_dir,file_dir,out_dir,filename,'_step4']);

    %% Step 5 Event segmentation (Starting from here, you need to modify the following sripts based on different types of analysis)
    % This is specifically for saccade and fixation analysis

    % Load parameter file
    edf = load_param_v3_mgs(edf);

    % First, we need to detect different trials and task epochs
    edf = detect_epoch_v3_mgs(edf,set);

    % Then, detect saccades in each trial
    edf = detect_saccades(edf,set);

    % save the data
    fprintf('\n');
    fprintf('saving .mat file...');
    save([data_dir,file_dir,out_dir,filename,'_step5']);

    %% Step 6 Select events of interest

    % select primary saccade during the response period
    edf = select_saccades_v3_mgs(edf,set); % select saccades

    % save the data
    fprintf('\n');
    fprintf('saving .mat file...');
    save([data_dir,file_dir,out_dir,filename,'_step6']);

end