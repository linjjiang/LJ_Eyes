addpath(genpath('C:\Users\lj104\Documents\Linjing_Research\EyeAnalysis\LJ_Eyes\LJ_Eyes_developing'))

%% Step 8 Statistical analysis and plotting

clear all
clc

% append data across runs
data_dir = 'C:\Users\lj104\Documents\Linjing_Research\thesis_data\images\Behavior\v3_short_delay\';

% We want to process each data folder separately
file_dirs = dir([data_dir 'SMGS*\s*']);

%%
clear subs runs
for ii = 1:length(file_dirs)
    subs{ii} = file_dirs(ii).name;
    runs(ii) = str2num(erase(file_dirs(ii).folder,[data_dir 'SMGS']));
end

subs_id = unique(subs);
runs_id = unique(runs);
%%
data = [];
for ii = 1:length(subs_id)
    ind = find(contains(subs,subs_id{ii}));
    for jj = 1:length(ind)
    file = dir([file_dirs(ind(jj)).folder '\' file_dirs(ind(jj)).name '\result\*step6.mat']);
    file_edf = load([file.folder '\' file.name]);
    data{ii,jj} = file_edf.edf;
    data_set{ii,jj} = file_edf.set;
    end
end

%% Data quality
param = nan(length(subs_id),length(runs_id),16,3);
for ii = 1:length(subs_id)
    for jj = 1:length(runs_id)
        if ~isempty(data{ii,jj})
        perc(ii,jj) = data{ii,jj}.trackloss.perc;
        nblink(ii,jj) = data{ii,jj}.blink.num;
        nnan(ii,jj) = data{ii,jj}.cal.num_nan;
        param_order(ii,jj,:) = data{ii,jj}.param.probe_order(1:16);
        param_quad(ii,jj,:) = data{ii,jj}.param.probe_quad(1:16);
        param_img(ii,jj,:) = data{ii,jj}.param.probe_img(1:16);
        else
            perc(ii,jj) = nan;
            nblink(ii,jj) = nan;
            nnan(ii,jj) = nan;
            param_order(ii,jj,:) = nan;
            param_quad(ii,jj,:) = nan;
            param_img(ii,jj,:) = nan;
        end
    end
end
qa.perc_mean = mean(perc,2);
qa.nblink_mean = mean(nblink,2)/16;
qa.nnan_all = sum(nnan,2);
qa.perc_run = perc;
qa.nblink_run = nblink;
qa.nnan_run = nnan;

%%
nanmean(qa.nnan_all/128*100)
std(qa.nnan_all/128*100,0,1,'omitnan')
%%
nnan_order = zeros(length(subs_id),4);
nnan_quad = nnan_order;
nnan_img = nnan_order;
for ii = 1:length(subs_id)
    for jj = 1:length(runs_id) 
        taskid = floor((jj-1)/4);
        if ~isempty(data{ii,jj})
            temp = [];
temp = squeeze(param_order(ii,jj,find(isnan(data{ii,jj}.cal.primary_sac_err))));
for kk = 1:length(temp)
nnan_order(ii,temp(kk)+taskid*4) = nnan_order(ii,temp(kk)) + 1;
end

            temp = [];
temp = squeeze(param_quad(ii,jj,find(isnan(data{ii,jj}.cal.primary_sac_err))));
for kk = 1:length(temp)
nnan_quad(ii,temp(kk)+taskid*4) = nnan_quad(ii,temp(kk)) + 1;
end

            temp = [];
temp = squeeze(param_img(ii,jj,find(isnan(data{ii,jj}.cal.primary_sac_err))));
for kk = 1:length(temp)
nnan_img(ii,temp(kk)+taskid*4) = nnan_img(ii,temp(kk)) + 1;
end
        end
    end
end
qa.nnan_order = nnan_order;
qa.nnan_quad = nnan_quad;
qa.nnan_img = nnan_img;

%%
save('qa.mat',"qa")
tbl = table(subs_id',qa.perc_mean,qa.nblink_mean,qa.nnan_all,'VariableNames',{'ID','% Sample Loss','Avg. No. Blinks Per Trial','No. Trials Excluded'});
writetable(tbl,'data_quality.csv')

%%  Get rid of incomplete dataset
data_nnan = qa.nnan_run./16.*100;
[row,col] = find(isnan(data_nnan));
data_nnan(unique(row),:) = nan;
unique(subs_id(row))
% row 1, 10, 14

% data1 = data_nnan(:,1:4);
% data2 = data_nnan(:,5:8);
% 
% % Stats analysis
% [ranovatbl,Mrm,mau,eps] = nWayRM(data1,'Run',{'run1','run2','run3','run4'});
% 
% comp = {[1 2];[1 3];[1 4];[2 3];[2 4];[3 4]};%table2cell(Mrm([1 2 3 5 6 9],1:2));
% p_val = table2array(Mrm([1 2 3 5 6 9],5));
% 
% figure(1);clf
% boxWithDots3(data1,{'run1','run2','run3','run4'},0,[0 0.4470 0.7410],p_val,comp)
% xlabel('Run')
% ylabel('Percentage of trials excluded (%)')
% title('Quadrant Cue')
% 
% % Stats analysis
% [ranovatbl,Mrm,mau,eps] = nWayRM(data2,'Run',{'run1','run2','run3','run4'});
% 
% comp = {[1 2];[1 3];[1 4];[2 3];[2 4];[3 4]};%table2cell(Mrm([1 2 3 5 6 9],1:2));
% p_val = table2array(Mrm([1 2 3 5 6 9],5));
% 
% figure(2);clf
% boxWithDots3(data2,{'run1','run2','run3','run4'},0,[0.8500 0.3250 0.0980],p_val,comp)
% xlabel('Run')
% ylabel('Percentage of trials excluded (%)')
% title('Order Cue')

%% Check percentage of trials excluded
% Stats analysis
[ranovatbl,Mrm,mau,eps,norm_p] = nWayRM(data_nnan,'Task',{'Quadrant Cue','Order Cue'},'Run',{'run1','run2','run3','run4'});
% nlev = 8; % how many levels
% comp = mat2cell(nchoosek(1:nlev,2),ones(size(nchoosek(1:nlev,2),1),1),2)
% ind = [];
% for ii = 1:nlev
%     temp = (ii-1)*(nlev-1) + [ii:(nlev-1)];
%     ind = [ind;temp'];
% end
% p_val = table2array(Mrm(ind,5));
comp = {[2.5 6.5]};
p_val = ranovatbl{3,5};

figure(3);clf
boxWithDots3(data_nnan,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 
xlabel('Run')
ylabel('Percentage of trials excluded (%)')
%ylim([0 80])
box off

%% Get rid of the outliers
% for ii = 1:8
% TF(:,ii) = isoutlier(data(:,ii));
% end

TF = isoutlier(data_nnan) | data_nnan > 40;
[row,col] = find(TF==1); % 14, 26 (p26, p38)
unique(subs_id(row)) % smgs v3_short: all the outliers - % outlier: 12, 15, 25, 27
data_clean = data_nnan; data_clean(unique(row),:) = nan;

% Stats analysis
[ranovatbl,Mrm,mau,eps,norm_p] = nWayRM(data_clean,'Task',{'Quadrant Cue','Order Cue'},'Run',{'run1','run2','run3','run4'});
comp = {[2.5 6.5]};
p_val = ranovatbl{3,5};

figure(3);clf
boxWithDots3(data_clean,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 
xlabel('Run')
ylabel('Percentage of trials excluded (%)')
%ylim([0 80])
box off

% [ranovatbl,Mrm,mau,eps] = nWayRM(data_clean,'Run',{'run1','run2','run3','run4','run5','run6','run7','run8'});
% nlev = 8; % how many levels
% comp = mat2cell(nchoosek(1:nlev,2),ones(size(nchoosek(1:nlev,2),1),1),2)
% ind = [];
% for ii = 1:nlev
%     temp = (ii-1)*(nlev-1) + [ii:(nlev-1)];
%     ind = [ind;temp'];
% end
% p_val = table2array(Mrm(ind,5));
% 
% figure(3);clf
% boxWithDots3(data_clean,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
%    [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 
% xlabel('Run')
% ylabel('Percentage of trials excluded (%)')
% box off

% %% check trials excluded for different ordered positions
% % data_nnan = qa.nnan_order./16.*100;
% % [row,col] = find(isnan(data_nnan));
% % data_nnan(unique(row),:) = nan;
% 
% % Stats analysis
% [ranovatbl,Mrm,mau,eps] = nWayRM(data_clean,'Task',{'Quadrant Cue','Order Cue'},'Order',{'First','Second','Third','Fourth'});
% % nlev = 4; % how many levels
% % comp = mat2cell(nchoosek(1:nlev,2),ones(size(nchoosek(1:nlev,2),1),1),2)
% % ind = [];
% % for ii = 1:nlev
% %     temp = (ii-1)*(nlev-1) + [ii:(nlev-1)];
% %     ind = [ind;temp'];
% % end
% % p_val = table2array(Mrm(ind,5));
% comp = {[2.5 6.5]};
% p_val = ranovatbl{3,5};
% 
% figure(3);clf
% boxWithDots3(data_clean,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
%    [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 
% xlabel('Order')
% ylabel('Percentage of trials excluded (%)')
% %ylim([0 80])
% box off

% %% After excluding outliers
% data_clean = data_nnan; data_clean([14,26],:) = [];
% 
% % Stats analysis
% [ranovatbl,Mrm,mau,eps] = nWayRM(data_clean,'Order',{'First','Second','Third','Fourth'});
% nlev = 4; % how many levels
% comp = mat2cell(nchoosek(1:nlev,2),ones(size(nchoosek(1:nlev,2),1),1),2)
% ind = [];
% for ii = 1:nlev
%     temp = (ii-1)*(nlev-1) + [ii:(nlev-1)];
%     ind = [ind;temp'];
% end
% p_val = table2array(Mrm(ind,5));
% 
% figure(3);clf
% boxWithDots3(data_clean,{'First','Second','Third','Fourth'},0,...
%    [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 
% xlabel('Order')
% ylabel('Percentage of trials excluded (%)')
% box off
%%
mkdir('C:\Users\lj104\Documents\Linjing_Research\thesis_data\images\Analysis\Behavior\v3_short\sMGS\')
save('C:\Users\lj104\Documents\Linjing_Research\thesis_data\images\Analysis\Behavior\v3_short\sMGS\analysis_1004.mat','-v7.3')

%% final subjects included
final_sind = find(~isnan(data_clean(:,1))); %

%% Plot superimposed gaze path
% for ii = final_sind
%     data{ii,jj}
% end

% change the following before your proceed
ii = 5;
%ii = final_sind(1);
% plot all the trials (1:16) or just valid trials (find...)
%final_tr =  1:16;
final_tr = find(~isnan(data{ii,jj}.cal.primary_sac_err)); % valid trials
sample_rate = data{1,1}.record.sample_rate;
%
x_trial_all_mat = []; y_trial_all_mat = []; tarx = []; tary = [];
x_trial_all_flip_mat = []; y_trial_all_flip_mat = [];
for jj = 1:8
% 1, start
% 2, fixation
% 3, 5, 7, 9, targets
% 10, delay
% 11, cue
% 13, iti
% 14, end
eye = mod(contains(data{ii,1}.record.eye,'left')+1,2)+1;
%eye = contains(data{ii,jj}.record.eye,'left');
x = data{ii,jj}.samples.x_deg_clean(:,eye); 
y = data{ii,jj}.samples.y_deg_clean(:,eye);

% event start
ev_srt = data{ii,jj}.events.msg.ind_srt(:,[1 2 3 5 7 9 10 11 13 14]); 

% duration of each task period
ev_len = diff(ev_srt,1,2);

% mainly focus on the delay period
delay_len = round(ev_len(:,7)/1000)*1000;

% which trials need to fill in the na values
delay_len_add = max(delay_len) - delay_len;

% we want to start a trial 500ms before 
ev_srt_new = ev_srt;
ev_srt_new(:,1) = [];
ev_srt_new(:,1) = ev_srt_new(:,2)-500/1000*sample_rate;
ev_srt_new(:,end) = [];

% plotted event timing
ev_plot = [500 1000 1000 1000 500 6000 1500];
ev_plot = cumsum(ev_plot);

% max trial length
tr_len = ev_srt_new(:,end)-ev_srt_new(:,1)+1+delay_len_add;

% get the samples trial by trial
% for ii = 1:16
% x_trial{ii} = [x(ev_srt_new(ii,1):ev_srt_new(ii,7));nan(delay_len_add(ii),1);x((ev_srt_new(ii,7)+1):ev_srt_new(ii,end))];
% y_trial{ii} = [y(ev_srt_new(ii,1):ev_srt_new(ii,7));nan(delay_len_add(ii),1);y((ev_srt_new(ii,7)+1):ev_srt_new(ii,end))];
% tr_len(ii) = length(x_trial{ii});
% end
clear x_trial y_trial
for kk = 1:16
x_trial(:,kk) = [x(ev_srt_new(kk,1):ev_srt_new(kk,7));nan(delay_len_add(kk),1);x((ev_srt_new(kk,7)+1):ev_srt_new(kk,end));nan(max(tr_len)-tr_len(kk),1)];
y_trial(:,kk) = [y(ev_srt_new(kk,1):ev_srt_new(kk,7));nan(delay_len_add(kk),1);y((ev_srt_new(kk,7)+1):ev_srt_new(kk,end));nan(max(tr_len)-tr_len(kk),1)];
end

x_trial_all{jj,1} = x_trial(:,final_tr); % only select subset of trials
y_trial_all{jj,1} = y_trial(:,final_tr);
run_len(jj) = size(x_trial,1);

tarx = [tarx,data{ii,jj}.param.tarx_deg(final_tr)'];
tary = [tary,data{ii,jj}.param.tary_deg(final_tr)'];

xsign = sign(data{ii,jj}.param.tarx_deg(final_tr));
ysign = sign(data{ii,jj}.param.tary_deg(final_tr));

% x will be positive; y will be all negative
x_trial_all_flip{jj,1} = x_trial_all{jj,1}.*xsign';
y_trial_all_flip{jj,1} = y_trial_all{jj,1}.*(-ysign)';

end

for jj = 1:8
    %final_tr =  1:16;%find(~isnan(data{ii,jj}.cal.primary_sac_err)); % valid trials

x_trial_all_mat = [x_trial_all_mat,[x_trial_all{jj,1};nan(max(run_len)-run_len(jj),length(final_tr))]];
y_trial_all_mat = [y_trial_all_mat,[y_trial_all{jj,1};nan(max(run_len)-run_len(jj),length(final_tr))]];
x_trial_all_flip_mat = [x_trial_all_flip_mat,[x_trial_all_flip{jj,1};nan(max(run_len)-run_len(jj),length(final_tr))]];
y_trial_all_flip_mat = [y_trial_all_flip_mat,[y_trial_all_flip{jj,1};nan(max(run_len)-run_len(jj),length(final_tr))]];

end

%%
% plot
figure(1);clf
h = plot(x_trial_all_mat,y_trial_all_mat)
xlim([-6 6])
ylim([-6 6])
hold on
scatter(tarx,tary,30,'k','+')
box off
axis equal
%axis off
% %%
% % plot gaze path
% % figure out excluded trials
% %final_tr =  find(~isnan(data{1,1}.cal.primary_sac_err));
% tm = (1:tr_len)*2/1000;
% figure(2);clf
% for ii = final_tr
% plot(tm,x_trial(:,ii),'Color',[0 0.4470 0.7410])
% hold on
% end
% xlim([0 16])
% ylim([-6 6])
% 
% for ii = 1:length(ev_plot)-1
% line([ev_plot(ii) ev_plot(ii)]*2/1000,[-6 6],'Color','k','LineStyle','--')
% hold on
% end

%% flip x/y and replot gaze path
% xsign = sign(data{1, 1}.param.tarx_deg(1:16));
% ysign = sign(data{1, 1}.param.tary_deg(1:16));
% 
% % x will be positive; y will be all negative
% x_trial_flip = x_trial.*xsign';
% y_trial_flip = y_trial.*(-ysign)';

tm = (1:max(run_len))/sample_rate;
figure(3);clf
for ii = 1:size(x_trial_all_flip_mat,2)
plot(tm,x_trial_all_flip_mat(:,ii),'Color',[0 0.4470 0.7410],'LineWidth',1)
hold on
plot(tm,y_trial_all_flip_mat(:,ii),'Color',[0.8500 0.3250 0.0980],'LineWidth',1)
hold on
end

xlim([0 12])
ylim([-8 8])

for ii = 1:length(ev_plot)-1
line([ev_plot(ii) ev_plot(ii)]/1000,[-8 8],'Color','k','LineStyle','--')
hold on
end

xlabel('Time (sec)')
ylabel('Gaze Position (dva)')
set(gca,'FontSize',20)
% %% average gaze path
% tm = (1:max(run_len))*2/1000;
% 
% x_trial_avg = nanmean(x_trial_all_flip_mat,2);
% y_trial_avg = nanmean(y_trial_all_flip_mat,2);
% x_trial_std = std(x_trial_all_flip_mat,0,2,"omitnan");
% y_trial_std = std(y_trial_all_flip_mat,0,2,"omitnan");
% 
% figure(4);clf
% 
% y1 = y_trial_avg + y_trial_std;
% y2 = y_trial_avg - y_trial_std;
% tm1 = [tm, fliplr(tm)];
% inBetween = [y1',fliplr(y2')];
% h = fill(tm1, inBetween,[0.8500 0.3250 0.0980]);
% h.EdgeColor = [0.8500 0.3250 0.0980];
% h.EdgeAlpha = 0.3;
% h.FaceAlpha = 0.3;
% hold on
% x1 = x_trial_avg + x_trial_std;
% x2 = x_trial_avg - x_trial_std;
% tm1 = [tm, fliplr(tm)];
% inBetween = [x1',fliplr(x2')];
% h = fill(tm1, inBetween,[0 0.4470 0.7410]);
% h.EdgeColor = [0 0.4470 0.7410];
% h.EdgeAlpha = 0.3;
% h.FaceAlpha = 0.3;
% hold on
% plot(tm,x_trial_avg,'Color',[0 0.4470 0.7410],'LineWidth',3)
% hold on
% plot(tm,y_trial_avg,'Color',[0.8500 0.3250 0.0980],'LineWidth',3)
% hold on
% 
% 
% hold on;
% xlim([0 16])
% ylim([-8 8])
% 
% for ii = 1:length(ev_plot)-1
% line([ev_plot(ii) ev_plot(ii)]*2/1000,[-8 8],'Color','k','LineStyle','--')
% hold on
% end

%% plot target

figure(1);clf
for jj = 1:8
subplot(2,4,jj)
scatter(data{1,jj}.param.tarx_deg,data{1,jj}.param.tary_deg,5)
hold on
line([-6 6],[0 0],'LineStyle','--')
line([0 0],[-6 6],'LineStyle','--')
xlim([-6 6])
ylim([-6 6])
title(num2str(jj))
end

%% together
figure(2);clf
for jj = 1:8
scatter(data{1, jj}.param.datasource{1:16,42}-640,data{1, jj}.param.datasource{1:16,43}-512,20,'LineWidth',2)
hold on
end
line([-512 512],[0 0],'LineStyle','--','LineWidth',2,'Color','k')
line([0 0],[-512 512],'LineStyle','--','LineWidth',2,'Color','k')
xlim([-512 512])
ylim([-512 512])

%% heatmap
% quadrant cue vs. order cue, one subject
task = {'Quadrant Cue','Order Cue'};
for kk = [1:3 5:14]%1:length(final_sind)
    ii = kk;%final_sind(kk);
figure(1);clf

XERR = cell(2,1);
YERR = cell(2,1);
for jj = 1:8
    ind = data{ii, jj}.cal.primary_sac_ind;
    xend = data{ii, jj}.events.sac.x_end;
    yend = data{ii, jj}.events.sac.y_end;
    xsrt = data{ii, jj}.events.sac.x_srt;
    ysrt = data{ii, jj}.events.sac.y_srt;
    xtar = data{ii,jj}.param.tarx_deg(~isnan(ind));
    ytar = data{ii,jj}.param.tary_deg(~isnan(ind));


    xerr = xend(ind(~isnan(ind))) - xtar;
    yerr = yend(ind(~isnan(ind))) - ytar;

    col = floor((jj-1)/4)+1;
    XERR{col} = [XERR{col};xerr];
    YERR{col} = [YERR{col};yerr];
    
end

cbottom = 0; ctop = .1;
for pp = 1:2 % two tasks
    subplot(1,2,pp)
    xerr = reshape(XERR{pp},[],1);
    yerr = reshape(YERR{pp},[],1);

    x_values = [-3:0.1:3];

   % Estimate a continuous pdf from the discrete data
[pdfx xi]= ksdensity(xerr,x_values);
[pdfy yi]= ksdensity(yerr,x_values);
%Create 2-d grid of coordinates and function values, suitable for 3-d plotting
[xxi,yyi]     = meshgrid(xi,yi);
[pdfxx,pdfyy] = meshgrid(pdfx,pdfy);
%Calculate combined pdf, under assumption of independence
pdfxy = pdfxx.*pdfyy; %pdfxy = mat2gray(pdfxy); 
%Plot the results
h = surf(xxi,yyi,pdfxy,'linestyle','none');
shading interp
caxis manual
caxis([cbottom ctop]);
set(gca,'XLim',[-3 3],'XTick',[-3 0 3],'FontSize',14)
set(gca,'YLim',[-3 3],'YTick',[-3 0 3])

c=jet(100);
colormap(c(1:100,:));
view(2)

hold on
z_max = max(max(get(h,'Zdata')));
%scatter3(X,Y,z_max*ones(size(X)),5,'MarkerEdgeColor','k','MarkerFaceColor',[1 1 1])
scatter3(xerr,yerr,z_max*ones(size(xerr)),5,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 1])
view(2)
hold on
h1 = scatter3(0,0,1,700,'+','MarkerEdgeColor','k',...
   'MarkerFaceColor','none','LineWidth',5); %uint8([255 255 255])
colorbar('location','Manual', 'position', [0.93 0.2 0.02 0.6]);
set(gca,'XTick',[],'YTick',[])
title(task{pp})
%axis equal
end
saveas(figure(1),[subs_id{ii},'_heatmap.jpg'])
end

%% run 1-8, quadrant & order cue, stats
%mkdir('cue')
%cd cue
sb = [1:8 10:12 14:length(subs_id)];

for ss = 1:length(final_sind)%1:size(data,1) % each subject
    ii = final_sind(ss);
p_ord = []; p_quad = []; p_img = [];
p_err = []; a_err = []; n_sac = []; p_rt = []; p_task=[];
p_xend = []; p_yend = []; p_xtar = []; p_ytar = [];

for jj = 1:8 % each run
% task
p_task = [p_task; floor((jj-1)/4)*ones(16,1)];

% probe_order
p_ord = [p_ord;data{ii,jj}.param.probe_order(1:16)];

% probe quadrant
p_quad = [p_quad;data{ii,jj}.param.probe_quad(1:16)];

% probe image
p_img = [p_img;data{ii,jj}.param.probe_img(1:16)];

% Primary saccade
p_err = [p_err;data{ii,jj}.cal.primary_sac_err];

% Most accurate saccade
a_err = [a_err;data{ii,jj}.cal.acc_sac_err];
% Number of saccades
n_sac = [n_sac;data{ii,jj}.cal.num_sac(:,1)];

% latency
p_rt = [p_rt;data{ii,jj}.cal.primary_sac_rt];

% systematic error
xend = data{ii,jj}.cal.primary_sac_xend;
yend = data{ii,jj}.cal.primary_sac_yend;
xtar = data{ii,jj}.param.tarx_deg(1:16);
ytar = data{ii,jj}.param.tary_deg(1:16);

p_xend = [p_xend;xend];
p_yend = [p_yend;yend];
p_xtar = [p_xtar;xtar];
p_ytar = [p_ytar;ytar];

end

% Effects of encoding order
for kk = 1:4
    for hh = 1:2
    ind = find(p_ord==kk & p_task==hh-1);
p_err_new(:,kk+(hh-1)*4) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk+(hh-1)*4) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk+(hh-1)*4) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk+(hh-1)*4) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk+(hh-1)*4) = sum(~isnan(p_err(ind)));

p_xend_new(:,kk+(hh-1)*4) = [p_xend(ind);nan(16-length(ind),1)];
p_yend_new(:,kk+(hh-1)*4) = [p_yend(ind);nan(16-length(ind),1)];
p_xtar_new(:,kk+(hh-1)*4) = [p_xtar(ind);nan(16-length(ind),1)];
p_ytar_new(:,kk+(hh-1)*4) = [p_ytar(ind);nan(16-length(ind),1)];
end
end
stats.p_err_ord(ii,:,:) = p_err_new;
stats.a_err_ord(ii,:,:) = a_err_new;
stats.n_sac_ord(ii,:,:) = n_sac_new;
stats.p_rt_ord(ii,:,:) = p_rt_new;
stats.n_tr_ord(ii,:,:) = n_tr;
stats.p_xend_ord(ii,:,:) = p_xend_new;
stats.p_yend_ord(ii,:,:) = p_yend_new;
stats.p_xtar_ord(ii,:,:) = p_xtar_new;
stats.p_ytar_ord(ii,:,:) = p_ytar_new;
[stats.p_sys_ord(ii,:),stats.p_unsys_ord(ii,:)] = cal_sys_unsys(p_xend_new,p_yend_new,p_xtar_new,p_ytar_new);

% Effects of quadrant
for kk = 1:4
    for hh = 1:2
    ind = find(p_quad==kk & p_task==hh-1);
p_err_new(:,kk+(hh-1)*4) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk+(hh-1)*4) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk+(hh-1)*4) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk+(hh-1)*4) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk+(hh-1)*4) = sum(~isnan(p_err(ind)));
p_xend_new(:,kk+(hh-1)*4) = [p_xend(ind);nan(16-length(ind),1)];
p_yend_new(:,kk+(hh-1)*4) = [p_yend(ind);nan(16-length(ind),1)];
p_xtar_new(:,kk+(hh-1)*4) = [p_xtar(ind);nan(16-length(ind),1)];
p_ytar_new(:,kk+(hh-1)*4) = [p_ytar(ind);nan(16-length(ind),1)];

end
end

stats.p_err_quad(ii,:,:) = p_err_new;
stats.a_err_quad(ii,:,:) = a_err_new;
stats.n_sac_quad(ii,:,:) = n_sac_new;
stats.p_rt_quad(ii,:,:) = p_rt_new;
stats.n_tr_quad(ii,:,:) = n_tr;
stats.p_xend_quad(ii,:,:) = p_xend_new;
stats.p_yend_quad(ii,:,:) = p_yend_new;
stats.p_xtar_quad(ii,:,:) = p_xtar_new;
stats.p_ytar_quad(ii,:,:) = p_ytar_new;
[stats.p_sys_quad(ii,:),stats.p_unsys_quad(ii,:)] = cal_sys_unsys(p_xend_new,p_yend_new,p_xtar_new,p_ytar_new);

% Effects of image category

for kk = 1:4
    for hh = 1:2
    ind = find(p_img==kk & p_task==hh-1);
p_err_new(:,kk+(hh-1)*4) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk+(hh-1)*4) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk+(hh-1)*4) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk+(hh-1)*4) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk+(hh-1)*4) = sum(~isnan(p_err(ind)));
p_xend_new(:,kk+(hh-1)*4) = [p_xend(ind);nan(16-length(ind),1)];
p_yend_new(:,kk+(hh-1)*4) = [p_yend(ind);nan(16-length(ind),1)];
p_xtar_new(:,kk+(hh-1)*4) = [p_xtar(ind);nan(16-length(ind),1)];
p_ytar_new(:,kk+(hh-1)*4) = [p_ytar(ind);nan(16-length(ind),1)];

end
end
stats.p_err_img(ii,:,:) = p_err_new;
stats.a_err_img(ii,:,:) = a_err_new;
stats.n_sac_img(ii,:,:) = n_sac_new;
stats.p_rt_img(ii,:,:) = p_rt_new;
stats.n_tr_img(ii,:,:) = n_tr;
stats.p_xend_img(ii,:,:) = p_xend_new;
stats.p_yend_img(ii,:,:) = p_yend_new;
stats.p_xtar_img(ii,:,:) = p_xtar_new;
stats.p_ytar_img(ii,:,:) = p_ytar_new;
[stats.p_sys_img(ii,:),stats.p_unsys_img(ii,:)] = cal_sys_unsys(p_xend_new,p_yend_new,p_xtar_new,p_ytar_new);
end

fn = fieldnames(stats);
for k=1:numel(fn)
    stats.(fn{k})(stats.(fn{k}) == 0) = nan;
end

save('stats.mat','stats')
    
% %% run 1-4, quadrant cue, for each subject
% mkdir('quadrant_cue')
% cd quadrant_cue
% sb = [1:8 10:12 14:29];
% 
% for ii = sb%1:size(data,1) % each subject
% p_ord = []; p_quad = []; p_img = [];
% p_err = []; a_err = []; n_sac = []; p_rt = [];
% 
% for jj = 1:4 % each run
% % probe_order
% p_ord = [p_ord;data{ii,jj}.param.probe_order(1:16)];
% 
% % probe quadrant
% p_quad = [p_quad;data{ii,jj}.param.probe_quad(1:16)];
% 
% % probe image
% p_img = [p_img;data{ii,jj}.param.probe_img(1:16)];
% 
% % Primary saccade
% p_err = [p_err;data{ii,jj}.cal.primary_sac_err];
% 
% % Most accurate saccade
% a_err = [a_err;data{ii,jj}.cal.acc_sac_err];
% % Number of saccades
% n_sac = [n_sac;data{ii,jj}.cal.num_sac(:,1)];
% 
% % latency
% p_rt = [p_rt;data{ii,jj}.cal.primary_sac_rt];
% end
% 
% % Effects of encoding order
% for kk = 1:4
%     ind = find(p_ord==kk);
% p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
% a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
% n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
% p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
% n_tr(1,kk) = sum(~isnan(p_err(ind)));
% end
% 
% stats.p_err_ord(ii,:,:) = p_err_new;
% stats.a_err_ord(ii,:,:) = a_err_new;
% stats.n_sac_ord(ii,:,:) = n_sac_new;
% stats.p_rt_ord(ii,:,:) = p_rt_new;
% stats.n_tr_ord(ii,:,:) = n_tr;
% 
% % Plot
% figure(1);clf
% boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Primary Saccade Error (dva)')
% saveas(figure(1),[subs_id{ii},'_pse_order.jpg']);
% 
% figure(2);clf
% boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Smallest Saccade Error (dva)')
% saveas(figure(2),[subs_id{ii},'_sse_order.jpg']);
% 
% figure(3);clf
% boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Number of Saccades <= 3.5 dva')
% saveas(figure(3),[subs_id{ii},'_nsac_order.jpg']);
% 
% figure(4);clf
% boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Latency (ms)')
% saveas(figure(4),[subs_id{ii},'_rt_order.jpg']);
% 
% % Effects of quadrant
% for kk = 1:4
%     ind = find(p_quad==kk);
% p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
% a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
% n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
% p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
% n_tr(1,kk) = sum(~isnan(p_err(ind)));
% end
% 
% stats.p_err_quad(ii,:,:) = p_err_new;
% stats.a_err_quad(ii,:,:) = a_err_new;
% stats.n_sac_quad(ii,:,:) = n_sac_new;
% stats.p_rt_quad(ii,:,:) = p_rt_new;
% stats.n_tr_quad(ii,:,:) = n_tr;
% 
% % Plot
% figure(1);clf
% boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Primary Saccade Error (dva)')
% saveas(figure(1),[subs_id{ii},'_pse_quad.jpg']);
% 
% figure(2);clf
% boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Smallest Saccade Error (dva)')
% saveas(figure(2),[subs_id{ii},'_sse_quad.jpg']);
% 
% figure(3);clf
% boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Number of Saccades <= 3.5 dva')
% saveas(figure(3),[subs_id{ii},'_nsac_quad.jpg']);
% 
% figure(4);clf
% boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Latency (ms)')
% saveas(figure(4),[subs_id{ii},'_rt_quad.jpg']);
% 
% % Effects of image category
% 
% for kk = 1:4
%     ind = find(p_img==kk);
% p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
% a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
% n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
% p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
% n_tr(1,kk) = sum(~isnan(p_err(ind)));
% end
% 
% stats.p_err_img(ii,:,:) = p_err_new;
% stats.a_err_img(ii,:,:) = a_err_new;
% stats.n_sac_img(ii,:,:) = n_sac_new;
% stats.p_rt_img(ii,:,:) = p_rt_new;
% stats.n_tr_img(ii,:,:) = n_tr;
% 
% % Plot
% figure(1);clf
% boxWithDots2(p_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Primary Saccade Error (dva)')
% saveas(figure(1),[subs_id{ii},'_pse_img.jpg']);
% 
% figure(2);clf
% boxWithDots2(a_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Smallest Saccade Error (dva)')
% saveas(figure(2),[subs_id{ii},'_sse_img.jpg']);
% 
% figure(3);clf
% boxWithDots2(n_sac_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Number of Saccades <= 3.5 dva')
% saveas(figure(3),[subs_id{ii},'_nsac_img.jpg']);
% 
% figure(4);clf
% boxWithDots2(p_rt_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Latency (ms)')
% saveas(figure(4),[subs_id{ii},'_rt_img.jpg']);
% 
% end
% 
% fn = fieldnames(stats);
% for k=1:numel(fn)
%     stats.(fn{k})(stats.(fn{k}) == 0) = nan;
% end
% 
% save('quad.mat','stats')

%% Error histogram - nothing much
for kk = 4%:length(final_sind)
    ii = final_sind(kk);
figure(1);clf
err1 = []; err2 = [];
for jj = 1:4 % quadrant task
err1 = [err1;data{ii,jj}.cal.primary_sac_err];
end
for jj = 5:8 % order task
    err2 = [err2;data{ii,jj}.cal.primary_sac_err];
end
histogram(err1)
hold on
histogram(err2)
end

%% Plotting each trial
% for ii = 1:size(data,1) % each subject
jj = 1; % run 1
tt = 1; % trial 5
% edf = data{ii,jj};
% set = data_set{ii,jj};

figure(1);clf
ind = find(edf.samples.trial == tt);
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
%title(['Gaze time course: trial ',num2str(tt),' sub ',subs_id{ii},' run',num2str(jj)])
hold on

indm = edf.events.msg.ind_srt;
for kk = 1:size(indm,2)
    h = line([tm(indm(tt,kk)),tm(indm(tt,kk))],[min([X(ind);Y(ind)]),max([X(ind);Y(ind)])],'LineStyle','--','Color','k');
    text(tm(indm(tt,kk)),max([X(ind);Y(ind)])*0.9,0,num2str(edf.events.msg.txt(tt,kk)));
end

% plot saccades
inds = find(edf.events.sac.trial == tt);
sac_on = edf.events.sac.ind_srt(inds);
sac_off = edf.events.sac.ind_end(inds);

for kk = 1:length(inds)
    ind1 = sac_on(kk):sac_off(kk);
    plot(tm(ind1),X(ind1),'LineWidth',4,'Color',[0, 0.4470, 0.7410]);
    plot(tm(ind1),Y(ind1),'LineWidth',4,'Color',[0.8500, 0.3250, 0.0980]);
end

% plot target
hold on
for kk = 1%1:4 % there is only one target each trial
line([tm(indm(tt,1)),tm(indm(tt,size(indm,2)))],[edf.param.tarx_deg(tt,kk),edf.param.tarx_deg(tt,kk)],'LineStyle','--','Color',[0, 0.4470, 0.7410])
line([tm(indm(tt,1)),tm(indm(tt,size(indm,2)))],[edf.param.tary_deg(tt,kk),edf.param.tary_deg(tt,kk)],'LineStyle','--','Color',[0.8500, 0.3250, 0.0980])
% scatter(tm(indm(ii,jj)),edf.param.tarx_deg(ii,jj),40,[0, 0.4470, 0.7410]) %  stimx_deg
% scatter(tm(indm(ii,jj)),edf.param.tary_deg(ii,jj),40,[0.8500, 0.3250, 0.0980]) %  stimy_deg
% hold on
end
% saveas(figure(1),[subs_id{ii},'_run',num2str(jj),'_trial',num2str(tt),'_gaze.jpg']);

% end

% for jj = 1:4   
% line([tm(ind(1)),tm(ind(end))],[edf.param.tarx_deg(ii,jj) edf.param.tarx_deg(ii,jj)],'LineStyle','--','Color',[0, 0.4470, 0.7410]);
% line([tm(ind(1)),tm(ind(end))],[edf.param.tary_deg(ii,jj) edf.param.tary_deg(ii,jj)],'LineStyle','--','Color',[0.8500, 0.3250, 0.0980]);
% text(tm(ind(end))*0.9,edf.param.tarx_deg(ii,jj)*1,0,num2str(jj),"Color",[0, 0.4470, 0.7410]);
% text(tm(ind(end))*0.9,edf.param.tary_deg(ii,jj)*1,0,num2str(jj),"Color",[0.8500, 0.3250, 0.0980]);
% hold on
% end


%% Group analysis
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_ord,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Order',{'First','Second','Third','Fourth'});

p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

% p_val = Mrm.one{1,5};
% comp = {[2.5 6.5]};

figure(1);clf
boxWithDots3(temp,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Encoding Order')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_ord.jpg')
writematrix(temp,'pse_ord.csv')
%%
% standard deviation
temp = squeeze(std(stats.p_err_ord,0,2,"omitnan"));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Order',{'First','Second','Third','Fourth'});

p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Encoding Order')
ylabel('STDEV Primary Saccade Error (dva)')
saveas(figure(1),'pse_ord_std.jpg')
writematrix(temp,'pse_ord_std.csv')
%%
% rt
temp = squeeze(nanmean(stats.p_rt_ord,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Order',{'First','Second','Third','Fourth'});

p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Encoding Order')
ylabel('Latency (ms)')
saveas(figure(1),'pse_ord_rt.jpg')
writematrix(temp,'pse_ord_rt.csv')

%% 2D error - systematic error
temp = stats.p_sys_ord;
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Order',{'First','Second','Third','Fourth'});

p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Encoding Order')
ylabel('2D Systematic Error (dva)')
saveas(figure(1),'pse_ord_sys.jpg')
writematrix(temp,'pse_ord_sys.csv')

%% 2D error - unsystematic error
temp = stats.p_unsys_ord;
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Order',{'First','Second','Third','Fourth'});

p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q1','Q2','Q3','Q4','O1','O2','O3','O4'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Encoding Order')
ylabel('2D Unsystematic Error (dva)')
saveas(figure(1),'pse_ord_unsys.jpg')
writematrix(temp,'pse_ord_unsys.csv')

%% quadrant effect
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_quad,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Quadrant',{'1','2','3','4'});

% p = Mrm.two{[1:3,5:6,9],5};
% comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
% p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
% comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];
p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q_URV','Q_ULV','Q_LLV','Q_LRV','O_URV','O_ULV','O_LLV','O_LRV'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Quadrant')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_quad.jpg')
writematrix(temp,'pse_quad.csv')

% calculate partial eta squared
% ss_effect/(ss_effect+ss_error)
ranovatbl{3,1}/(ranovatbl{3,1}+ranovatbl{4,1})
ranovatbl{5,1}/(ranovatbl{5,1}+ranovatbl{6,1})

%% quadrant
% rt
temp = squeeze(nanmean(stats.p_rt_quad,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Quadrant',{'1','2','3','4'});

% p = Mrm.two{[1:3,5:6,9],5};
% comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
% p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
% comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];
p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q_URV','Q_ULV','Q_LLV','Q_LRV','O_URV','O_ULV','O_LLV','O_LRV'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Quadrant')
ylabel('Latency (ms)')
saveas(figure(1),'pse_quad_rt.jpg')
writematrix(temp,'pse_quad_rt.csv')

%% image effect
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_img,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Image',{'1','2','3','4'});

% p = Mrm.two{[1:3,5:6,9],5};
% comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
% p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
% comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];
p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];


figure(1);clf
boxWithDots3(temp,{'F Face', 'M Face', 'House 1', 'House 2','F Face', 'M Face', 'House 1', 'House 2'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Image')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_img.jpg')
writematrix(temp,'pse_img.csv')

% calculate partial eta squared
% ss_effect/(ss_effect+ss_error)
ranovatbl{3,1}/(ranovatbl{3,1}+ranovatbl{4,1})
ranovatbl{5,1}/(ranovatbl{5,1}+ranovatbl{6,1})

%% image rt
temp = squeeze(nanmean(stats.p_rt_img,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Task',{'Quadrant Cue','Order Cue'},'Image',{'1','2','3','4'});

% p = Mrm.two{[1:3,5:6,9],5};
% comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
% p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
% comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];
p = Mrm.twoByone{[[1:3,5:6,9]+12,[1:3,5:6,9]],6};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3],...
    [1 4]+4,[1 2]+4,[1 3]+4,[4 2]+4,[4 3]+4,[2 3]+4};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];


figure(1);clf
boxWithDots3(temp,{'F Face', 'M Face', 'House 1', 'House 2','F Face', 'M Face', 'House 1', 'House 2'},0,...
   [repmat([0 0.4470 0.7410],4,1);repmat([0.8500 0.3250 0.0980],4,1)],p_val,comp) % 

xlabel('Image')
ylabel('Latency (ms)')
saveas(figure(1),'pse_rt_img.jpg')
writematrix(temp,'pse_rt_img.csv')

% calculate partial eta squared
% ss_effect/(ss_effect+ss_error)
ranovatbl{3,1}/(ranovatbl{3,1}+ranovatbl{4,1})
ranovatbl{5,1}/(ranovatbl{5,1}+ranovatbl{6,1})
% %% most accurate saccade error
% % mean
% temp = squeeze(nanmean(stats.a_err_ord,2));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Mean Smallest Saccade Error (dva)')
% saveas(figure(1),'ase_ord.jpg')
% 
% % standard deviation
% temp = squeeze(std(stats.a_err_ord,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('STDEV Smallest Saccade Error (dva)')
% saveas(figure(1),'ase_ord_std.jpg')
% 
% %% quadrant effect
% % primary saccade error
% % mean
% temp = squeeze(nanmean(stats.p_err_quad,2));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
% xlabel('Quadrant')
% ylabel('Mean Primary Saccade Error (dva)')
% saveas(figure(1),'pse_quad.jpg')
% 
% % standard deviation
% temp = squeeze(std(stats.p_err_quad,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
% xlabel('Quadrant')
% ylabel('STDEV Primary Saccade Error (dva)')
% saveas(figure(1),'pse_quad_std.jpg')
% 
% % rt
% temp = squeeze(mean(stats.p_rt_quad,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
% xlabel('Quadrant')
% ylabel('Mean Latency (ms)')
% saveas(figure(1),'pse_quad_rt.jpg')
% %% image effect
% % primary saccade error
% % mean
% temp = squeeze(nanmean(stats.p_err_img,2));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Mean Primary Saccade Error (dva)')
% saveas(figure(1),'pse_img.jpg')
% 
% % standard deviation
% temp = squeeze(std(stats.p_err_img,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('STDEV Primary Saccade Error (dva)')
% saveas(figure(1),'pse_img_std.jpg')
% 
% % rt
% temp = squeeze(mean(stats.p_rt_img,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Mean Latency (ms)')
% saveas(figure(1),'pse_img_rt.jpg')

% %% run 5-8, order cue, for each subject
% mkdir('order_cue')
% cd order_cue
% for ii = 14:18%1:size(data,1) % each subject
% p_ord = []; p_quad = []; p_img = [];
% p_err = []; a_err = []; n_sac = []; p_rt = [];
% 
% for jj = 5:8 % each run
% % probe_order
% p_ord = [p_ord;data{ii,jj}.param.probe_order(1:16)];
% 
% % probe quadrant
% p_quad = [p_quad;data{ii,jj}.param.probe_quad(1:16)];
% 
% % probe image
% p_img = [p_img;data{ii,jj}.param.probe_img(1:16)];
% 
% % Primary saccade
% p_err = [p_err;data{ii,jj}.cal.primary_sac_err];
% 
% % Most accurate saccade
% a_err = [a_err;data{ii,jj}.cal.acc_sac_err];
% % Number of saccades
% n_sac = [n_sac;data{ii,jj}.cal.num_sac(:,1)];
% 
% % latency
% p_rt = [p_rt;data{ii,jj}.cal.primary_sac_rt];
% end
% 
% % Effects of encoding order
% for kk = 1:4
%     ind = find(p_ord==kk);
% p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
% a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
% n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
% p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
% n_tr(1,kk) = sum(~isnan(p_err(ind)));
% end
% 
% stats.p_err_ord(ii,:,:) = p_err_new;
% stats.a_err_ord(ii,:,:) = a_err_new;
% stats.n_sac_ord(ii,:,:) = n_sac_new;
% stats.p_rt_ord(ii,:,:) = p_rt_new;
% stats.n_tr_ord(ii,:,:) = n_tr;
% 
% % Plot
% figure(1);clf
% boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Primary Saccade Error (dva)')
% saveas(figure(1),[subs_id{ii},'_pse_order.jpg']);
% 
% figure(2);clf
% boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Smallest Saccade Error (dva)')
% saveas(figure(2),[subs_id{ii},'_sse_order.jpg']);
% 
% figure(3);clf
% boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Number of Saccades <= 3.5 dva')
% saveas(figure(3),[subs_id{ii},'_nsac_order.jpg']);
% 
% figure(4);clf
% boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Latency (ms)')
% saveas(figure(4),[subs_id{ii},'_rt_order.jpg']);
% 
% % Effects of quadrant
% for kk = 1:4
%     ind = find(p_quad==kk);
% p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
% a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
% n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
% p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
% n_tr(1,kk) = sum(~isnan(p_err(ind)));
% end
% 
% stats.p_err_quad(ii,:,:) = p_err_new;
% stats.a_err_quad(ii,:,:) = a_err_new;
% stats.n_sac_quad(ii,:,:) = n_sac_new;
% stats.p_rt_quad(ii,:,:) = p_rt_new;
% stats.n_tr_quad(ii,:,:) = n_tr;
% 
% % Plot
% figure(1);clf
% boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Primary Saccade Error (dva)')
% saveas(figure(1),[subs_id{ii},'_pse_quad.jpg']);
% 
% figure(2);clf
% boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Smallest Saccade Error (dva)')
% saveas(figure(2),[subs_id{ii},'_sse_quad.jpg']);
% 
% figure(3);clf
% boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Number of Saccades <= 3.5 dva')
% saveas(figure(3),[subs_id{ii},'_nsac_quad.jpg']);
% 
% figure(4);clf
% boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Quadrant')
% ylabel('Latency (ms)')
% saveas(figure(4),[subs_id{ii},'_rt_quad.jpg']);
% 
% % Effects of image category
% 
% for kk = 1:4
%     ind = find(p_img==kk);
% p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
% a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
% n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
% p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
% n_tr(1,kk) = sum(~isnan(p_err(ind)));
% end
% 
% stats.p_err_img(ii,:,:) = p_err_new;
% stats.a_err_img(ii,:,:) = a_err_new;
% stats.n_sac_img(ii,:,:) = n_sac_new;
% stats.p_rt_img(ii,:,:) = p_rt_new;
% stats.n_tr_img(ii,:,:) = n_tr;
% 
% % Plot
% figure(1);clf
% boxWithDots2(p_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Primary Saccade Error (dva)')
% saveas(figure(1),[subs_id{ii},'_pse_img.jpg']);
% 
% figure(2);clf
% boxWithDots2(a_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Smallest Saccade Error (dva)')
% saveas(figure(2),[subs_id{ii},'_sse_img.jpg']);
% 
% figure(3);clf
% boxWithDots2(n_sac_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Number of Saccades <= 3.5 dva')
% saveas(figure(3),[subs_id{ii},'_nsac_img.jpg']);
% 
% figure(4);clf
% boxWithDots2(p_rt_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Latency (ms)')
% saveas(figure(4),[subs_id{ii},'_rt_img.jpg']);
% 
% end
% 
% fn = fieldnames(stats);
% for k=1:numel(fn)
%     stats.(fn{k})(stats.(fn{k}) == 0) = nan;
% end
% 
% save('order.mat','stats')
% %% Group analysis
% % primary saccade error
% % mean
% temp = squeeze(nanmean(stats.p_err_ord,2));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Mean Primary Saccade Error (dva)')
% saveas(figure(1),'pse_ord.jpg')
% 
% % standard deviation
% temp = squeeze(std(stats.p_err_ord,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('STDEV Primary Saccade Error (dva)')
% saveas(figure(1),'pse_ord_std.jpg')
% 
% % rt
% temp = squeeze(std(stats.p_rt_ord,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Latency (ms)')
% saveas(figure(1),'pse_ord_rt.jpg')
% 
% %% most accurate saccade error
% % mean
% temp = squeeze(nanmean(stats.a_err_ord,2));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Mean Primary Saccade Error (dva)')
% saveas(figure(1),'ase_ord.jpg')
% 
% % standard deviation
% temp = squeeze(std(stats.a_err_ord,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('STDEV Primary Saccade Error (dva)')
% saveas(figure(1),'ase_ord_std.jpg')
% 
% % rt
% temp = squeeze(mean(stats.p_rt_ord,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
% xlabel('Encoding Order')
% ylabel('Mean Latency (ms)')
% saveas(figure(1),'pse_ord_rt.jpg')
% %% quadrant effect
% % primary saccade error
% % mean
% temp = squeeze(nanmean(stats.p_err_quad,2));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
% xlabel('Quadrant')
% ylabel('Mean Primary Saccade Error (dva)')
% saveas(figure(1),'pse_quad.jpg')
% 
% % standard deviation
% temp = squeeze(std(stats.p_err_quad,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
% xlabel('Quadrant')
% ylabel('STDEV Primary Saccade Error (dva)')
% saveas(figure(1),'pse_quad_std.jpg')
% 
% % rt
% temp = squeeze(mean(stats.p_rt_quad,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
% xlabel('Quadrant')
% ylabel('Mean Latency (ms)')
% saveas(figure(1),'pse_quad_rt.jpg')
% %% image effect
% % primary saccade error
% % mean
% temp = squeeze(nanmean(stats.p_err_img,2));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Mean Primary Saccade Error (dva)')
% saveas(figure(1),'pse_img.jpg')
% 
% % standard deviation
% temp = squeeze(std(stats.p_err_img,0,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('STDEV Primary Saccade Error (dva)')
% saveas(figure(1),'pse_img_std.jpg')
% 
% % rt
% temp = squeeze(mean(stats.p_rt_img,2,"omitnan"));
% [ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});
% 
% figure(1);clf
% boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
% xlabel('Image')
% ylabel('Mean Latency (ms)')
% saveas(figure(1),'pse_img_rt.jpg')

