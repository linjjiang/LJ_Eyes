clear all
close all
clc

% set up the top directory
top_dir = 'C:/Users/lj104/OneDrive/Documents/Linjing_Research/Eyetracker_Behavior/Eyetracker_Behavior/';

addpath(genpath(top_dir))
addpath(genpath('D:/linjing_eyetracking/'))

cd(top_dir)

sub_dir = dir('5*');
out_dir = 'result/';

for ii = 1:length(sub_dir)
   file_dir = [sub_dir(ii).name,'/','Metacognition/Eye_Tracker_Data/'];
   cd([top_dir,file_dir,out_dir])
   
   file = dir('*.mat');
   for jj = 1:length(file)
   clearvars edf1 edf
   close all
   
   all_edf{ii,jj} = load(file(jj).name,'edf');
   all_set{ii,jj} = load(file(jj).name,'set');
   
   edf = all_edf{ii,jj}.edf;
b = edf.trackloss.blink_ind;
o = edf.trackloss.outside_ind;
e = edf.trackloss.ext_ind;
t = unique(cat(1,b,o,e));
all = edf.samples.time;

b_perc(ii,jj) = length(b)/length(all)*100;
o_perc(ii,jj) = length(o)/length(all)*100;
e_perc(ii,jj) = length(e)/length(all)*100;
all_perc(ii,jj) = length(t)/length(all)*100;

calib_avg(ii,jj) = edf.calib.avg_error(1);
calib_max(ii,jj) = edf.calib.max_error(1);
   end
end

%% Plot the trackloss data
for ii = 1:3
    f = figure(ii)
    x = [1 2 3 4];
    y = [b_perc(ii,:);o_perc(ii,:);e_perc(ii,:);all_perc(ii,:)]';
    bar(x,y);
    legend({'Blink','Gaze Outside','Extreme Pupil Size','Total Trackloss'})
    xlabel('Session')
    ylabel('Percentage (%)')
    set(gca,'ylim',[0 100])
    title(['Subject ',num2str(ii)])
    saveas(f,['Trackloss ','Subject ',num2str(ii),'.jpg'])
end

%% plot the calibration results
for ii = 1:3
        f = figure(ii)
    x = [1 2 3 4];
    y = [calib_avg(ii,:);calib_max(ii,:)];
    bar(x,y);
    xlabel('Session')
    ylabel('Calibration Error (deg)')
    title(['Subject ',num2str(ii)])
    
    hold on
    line([0.5 4.5],[0.5 0.5],'LineWidth',2,'color','k')
    line([0.5 4.5],[1 1],'LineWidth',2,'color','b')
    legend({'Average Calibration Error','Maximum Calibration Error','Average Error (Standard)','Maximum Error (Standard)'})

    saveas(f,['Calibration ','Subject ',num2str(ii),'.jpg'])

end

%%
save('trackloss.mat','b_perc','e_perc','o_perc','all_perc','all_edf','all_set','calib_avg','calib_max')