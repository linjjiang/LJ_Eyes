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
% MAKE SURE YOU END THE DIRECTORY WITH A SLASH!!!
data_dir = 'C:\Users\lj104\Documents\Linjing_Research\thesis_data\images\Behavior\v1_1\sMGS\';

% Set up any subfolder under top_dir indicating different subjects or
% recording sessions, e.g.,'1000/'
% Make sure that there is a single edf file under this folder
file_dir = 'p3_1\'; % Here we do not have a subfolder
addpath(genpath([data_dir file_dir]))

% Set up the script directory, where you store the scripts
script_dir = 'C:\Users\lj104\Documents\Linjing_Research\EyeAnalysis\LJ_Eyes-main\LJ_Eyes-main\';
addpath(genpath(script_dir))

% Set up the output folder UNDER data_dir
out_dir = 'result\'; % In this case, the output will appear in data_dir + out_dir

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
% open v3_reptOne_setting
% pause
set = v3_reptOne_setting();

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
edf = get_screen_size(edf,1,60,37.7,30.2,1280,1024);

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

cd([data_dir,file_dir]) % make sure you entered the data folder
edf_file = dir('*.edf');
filename = erase(edf_file.name,'.edf'); edf.ID = filename;
save([out_dir,filename,'_step2']);

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
% 
% % Now, you should visually inspect blinks (optional if you are analyzing gaze locations)
% % If you are doing blink analysis, this step is a MUST
% % You should manually check all the blinks and see if those are truly
% % blinks, not other types of artifacts
% miniEye_ver0;
% % However, at this point, you can only inspect the blinks (its onset and
% % offset) without manually editing it. In the future I will add more
% % editing function to the GUI so that you can modify the blink events
% % directly using the toolbox

%% Step 4 Data Cleaning

close all

% Then, we need to remove artifacts from both the gaze and the pupil data
edf = remove_artifact(edf,set);

% Plot the time courses after artifact removal(automatically generate
% figures)
plot_timecourse_clean(edf,data_dir,file_dir,out_dir,set);
% % Alternatively, you can also inspect the data with our GUI
% miniEye_ver0;

% IF YOU ARE ANALYZING PUPIL SIZE:
% Do spatial interpolation of the pupil data
edf = do_interpolation(edf,set);

% Then do baseline correction if needed
% Here we gave an exmaple of baseline correction for the pupil size
edf = baseline_correction(edf,set);

% % Now you can inspect all types of the data again. Compare different plots and see
% % what their main differences are!
% miniEye_ver0;

% save the data
fprintf('\n');
fprintf('saving .mat file...');
save([data_dir,file_dir,out_dir,filename,'_step4']);

%% Step 5 Event segmentation
% This is specifically for saccade and fixation analysis

% Load parameter file
edf = load_param_v3_one(edf,set);

% First, we need to detect different trials and task epochs
edf = detect_epoch_v3_Behavior(edf,set);

% Then, detect saccades in each trial
edf = detect_saccades(edf,set);

% % Plot the events
% miniEye_ver0;
% Problem: messages are not displayed correctly
save([data_dir,file_dir,out_dir,filename,'_step5']);

%% Step 6 Select events of interest
% for ver. 1 & 2, need to correct for the inverted y location
% In e-builder, top-left corner of the screen = (0,0)
% So stimulus y location: y_res/2-tand(ecc)*d/h*y_res
% We need to flip quadrant cue 1 & 4, and 2 & 3
edf = correct_y(edf,set);
edf = select_saccades_one_v3(edf,set);
save([data_dir,file_dir,out_dir,filename,'_step6']);

%% Step 7 Group trials based on their experimental conditions

%% Step 8 Statistical analysis and plotting

% probe_order
p_ord = edf.param.probe_order;

% Primary saccade
p_err = edf.cal.primary_sac_err;

% Most accurate saccade
a_err = edf.cal.acc_sac_err;
% Number of saccades
n_sac = edf.cal.num_sac(:,1);

% latency
p_rt = edf.cal.primary_sac_rt;

for ii = 1:4
    ind = find(p_ord==ii);
p_err_new(:,ii) = [p_err(ind);nan(32-length(ind),1)];
a_err_new(:,ii) = [a_err(ind);nan(32-length(ind),1)];
n_sac_new(:,ii) = [n_sac(ind);nan(32-length(ind),1)];
p_rt_new(:,ii) = [p_rt(ind);nan(32-length(ind),1)];
n_tr(1,ii) = sum(~isnan(p_err(ind)));
end

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[data_dir,file_dir,out_dir,filename,'_pse_order.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[data_dir,file_dir,out_dir,filename,'_sse_order.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[data_dir,file_dir,out_dir,filename,'_nsac_order.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Latency (ms)')
saveas(figure(4),[data_dir,file_dir,out_dir,filename,'_rt_order.jpg']);

%% Effects of quadrant
p_quad = edf.param.probe_quad;

for ii = 1:4
    ind = find(p_quad==ii);
p_err_new(:,ii) = [p_err(ind);nan(32-length(ind),1)];
a_err_new(:,ii) = [a_err(ind);nan(32-length(ind),1)];
n_sac_new(:,ii) = [n_sac(ind);nan(32-length(ind),1)];
p_rt_new(:,ii) = [p_rt(ind);nan(32-length(ind),1)];
n_tr(1,ii) = sum(~isnan(p_err(ind)));
end

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[data_dir,file_dir,out_dir,filename,'_pse_quad.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[data_dir,file_dir,out_dir,filename,'_sse_quad.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[data_dir,file_dir,out_dir,filename,'_nsac_quad.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Latency (ms)')
saveas(figure(4),[data_dir,file_dir,out_dir,filename,'_rt_quad.jpg']);
%% Effects of image category
p_img = edf.param.probe_img;

for ii = 1:4
    ind = find(p_img==ii);
p_err_new(:,ii) = [p_err(ind);nan(32-length(ind),1)];
a_err_new(:,ii) = [a_err(ind);nan(32-length(ind),1)];
n_sac_new(:,ii) = [n_sac(ind);nan(32-length(ind),1)];
p_rt_new(:,ii) = [p_rt(ind);nan(32-length(ind),1)];
n_tr(1,ii) = sum(~isnan(p_err(ind)));
end

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[data_dir,file_dir,out_dir,filename,'_pse_img.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[data_dir,file_dir,out_dir,filename,'_sse_img.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[data_dir,file_dir,out_dir,filename,'_nsac_img.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Latency (ms)')
saveas(figure(4),[data_dir,file_dir,out_dir,filename,'_rt_img.jpg']);

%% Plotting
figure(1);clf
ii = 5; % trial 5
ind = find(edf.samples.trial == ii);
tm = edf.samples.time;
X = edf.samples.x_deg_clean(:,set.eye);
Y = edf.samples.y_deg_clean(:,set.eye);
plot(tm(ind),X(ind),'LineWidth',2,'Color',[0, 0.4470, 0.7410]);
hold on
plot(tm(ind),Y(ind),'LineWidth',2,'Color',[0.8500, 0.3250, 0.0980]);
xlim([tm(ind(1)) tm(ind(end))])
xlabel('Time (msec)')
ylabel('Eye Position (deg)')
legend off;
title(['Gaze time course: trial ',num2str(ii)])
hold on

indm = edf.events.msg.ind_srt;
for jj = 1:size(indm,2)
    h = line([tm(indm(ii,jj)),tm(indm(ii,jj))],[min([X(ind);Y(ind)]),max([X(ind);Y(ind)])],'LineStyle','--','Color','k');
    text(tm(indm(ii,jj)),max([X(ind);Y(ind)])*0.9,0,num2str(edf.events.msg.txt(ii,jj)));
end

% plot saccades
inds = find(edf.events.sac.trial == ii);
sac_on = edf.events.sac.ind_srt(inds);
sac_off = edf.events.sac.ind_end(inds);

for jj = 1:length(inds)
    ind1 = sac_on(jj):sac_off(jj);
    plot(tm(ind1),X(ind1),'LineWidth',6,'Color',[0, 0.4470, 0.7410]);
    plot(tm(ind1),Y(ind1),'LineWidth',6,'Color',[0.8500, 0.3250, 0.0980]);
end

% plot target
hold on
for jj = 1%1:4 % there is only one target each trial
line([tm(indm(ii,1)),tm(indm(ii,size(indm,2)))],[edf.param.tarx_deg(ii,jj),edf.param.tarx_deg(ii,jj)],'LineStyle','--','Color',[0, 0.4470, 0.7410])
line([tm(indm(ii,1)),tm(indm(ii,size(indm,2)))],[edf.param.tary_deg(ii,jj),edf.param.tary_deg(ii,jj)],'LineStyle','--','Color',[0.8500, 0.3250, 0.0980])
% scatter(tm(indm(ii,jj)),edf.param.tarx_deg(ii,jj),40,[0, 0.4470, 0.7410]) %  stimx_deg
% scatter(tm(indm(ii,jj)),edf.param.tary_deg(ii,jj),40,[0.8500, 0.3250, 0.0980]) %  stimy_deg
% hold on
end
saveas(figure(1),[data_dir,file_dir,out_dir,filename,'_trial',num2str(ii),'_gaze.jpg']);
% for jj = 1:4
%     
% line([tm(ind(1)),tm(ind(end))],[edf.param.tarx_deg(ii,jj) edf.param.tarx_deg(ii,jj)],'LineStyle','--','Color',[0, 0.4470, 0.7410]);
% line([tm(ind(1)),tm(ind(end))],[edf.param.tary_deg(ii,jj) edf.param.tary_deg(ii,jj)],'LineStyle','--','Color',[0.8500, 0.3250, 0.0980]);
% text(tm(ind(end))*0.9,edf.param.tarx_deg(ii,jj)*1,0,num2str(jj),"Color",[0, 0.4470, 0.7410]);
% text(tm(ind(end))*0.9,edf.param.tary_deg(ii,jj)*1,0,num2str(jj),"Color",[0.8500, 0.3250, 0.0980]);
% hold on
% end