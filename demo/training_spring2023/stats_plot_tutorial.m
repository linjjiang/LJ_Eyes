%% Statistical analysis and plotting tutorial
% For the mgs task

clear
close all
clc

% append data across runs
data_dir = 'C:\Users\lj104\Documents\Linjing_Research\thesis_data\images\Behavior\v3_short\';

% We want to process each data folder separately
file_dirs1 = dir([data_dir 'MGS*\p*']); % run*\p*
file_dirs2 = dir([data_dir 'MGS*\s*']); % run*\p*
file_dirs = [file_dirs1;file_dirs2];

%% find subject ids and runs
clear subs runs
for ii = 1:length(file_dirs)
    subs{ii} = file_dirs(ii).name;
    runs(ii) = str2num(erase(file_dirs(ii).folder,[data_dir 'MGS']));
end

subs_id = unique(subs);
runs_id = unique(runs);
%% combine all the datasets
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

%save([data_dir '/mgs_data.mat'],'-v7.3')

%% Data quality
param = nan(length(subs_id),length(runs_id),16,3);
for ii = 1:length(subs_id)
    for jj = 1:length(runs_id)
        if ~isempty(data{ii,jj})
        perc(ii,jj) = data{ii,jj}.trackloss.perc; % percentage of sample loss
        nblink(ii,jj) = data{ii,jj}.blink.num; % number of blinks
        nnan(ii,jj) = data{ii,jj}.cal.num_nan; % numer of misssed trials
        %param_order(ii,jj,:) = data{ii,jj}.param.probe_order(1:16);
        param_quad(ii,jj,:) = data{ii,jj}.param.probe_quad(1:16); % quadrants of the targets
        param_img(ii,jj,:) = data{ii,jj}.param.probe_img(1:16); % image category of the targets
        else
            perc(ii,jj) = nan;
            nblink(ii,jj) = nan;
            nnan(ii,jj) = nan;
            %param_order(ii,jj,:) = nan;
            param_quad(ii,jj,:) = nan;
            param_img(ii,jj,:) = nan;
        end
    end
end
qa.perc_mean = mean(perc,2);
qa.nblink_mean = mean(nblink,2)/16;
qa.nnan_all = sum(nnan,2); % number of missed trials
qa.perc_run = perc;
qa.nblink_run = nblink;
qa.nnan_run = nnan; % each run

%% mean and standard deviation of percentage of trials excluded
nanmean(qa.nnan_all/32*100)
std(qa.nnan_all/32*100,0,1,'omitnan')
%% the number of trials excluded for different quadrants and images
nnan_order = zeros(length(subs_id),4);
nnan_quad = nnan_order;
nnan_img = nnan_order;
for ii = 1:length(subs_id)
    for jj = 1:length(runs_id) 
        taskid = floor((jj-1)/4);
        if ~isempty(data{ii,jj})
%             temp = [];
% temp = squeeze(param_order(ii,jj,find(isnan(data{ii,jj}.cal.primary_sac_err))));
% for kk = 1:length(temp)
% nnan_order(ii,temp(kk)+taskid*4) = nnan_order(ii,temp(kk)) + 1;
% end

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
%qa.nnan_order = nnan_order;
qa.nnan_quad = nnan_quad;
qa.nnan_img = nnan_img;

%% save the qa results
save('qa_mgs.mat',"qa")
tbl = table(subs_id',qa.perc_mean,qa.nblink_mean,qa.nnan_all,'VariableNames',{'ID','% Sample Loss','Avg. No. Blinks Per Trial','No. Trials Excluded'});
writetable(tbl,'mgs_data_quality.csv')

%% Get rid of incomplete dataset
data_nnan = qa.nnan_run./16.*100;
[row,col] = find(isnan(data_nnan));
data_nnan(unique(row),:) = nan;

%%
% Stats analysis
[ranovatbl] = nWayRM(data_nnan,'Run',{'run1','run2'}); %Mrm,mau,eps,norm_p
% nlev = 8; % how many levels
% comp = mat2cell(nchoosek(1:nlev,2),ones(size(nchoosek(1:nlev,2),1),1),2)
% ind = [];
% for ii = 1:nlev
%     temp = (ii-1)*(nlev-1) + [ii:(nlev-1)];
%     ind = [ind;temp'];
% end
% p_val = table2array(Mrm(ind,5));
comp = {[1 2]};%{[2.5 6.5]};
p_val = ranovatbl{3,5};

figure(3);clf
boxWithDots3(data_nnan,{'MGS1','MGS2'},0,...
   [repmat([0 0.4470 0.7410],1,1);repmat([0.8500 0.3250 0.0980],1,1)],p_val,comp) % 
xlabel('Run')
ylabel('Percentage of trials excluded (%)')
ylim([0 80])
box off

%% Get rid of the outliers
% for ii = 1:8
% TF(:,ii) = isoutlier(data(:,ii));
% end
TF = isoutlier(data_nnan);
[row,col] = find(TF==1); % 14, 26 (p26, p38)
data_clean = data_nnan; data_clean(unique(row),:) = [];

% Stats analysis
[ranovatbl,Mrm,mau,eps] = nWayRM(data_clean,'Run',{'run1','run2'});
nlev = 2; % how many levels
comp = mat2cell(nchoosek(1:nlev,2),ones(size(nchoosek(1:nlev,2),1),1),2)
ind = [];
for ii = 1:nlev
    temp = (ii-1)*(nlev-1) + [ii:(nlev-1)];
    ind = [ind;temp'];
end
p_val = table2array(Mrm(ind,5));

figure(3);clf
boxWithDots3(data_clean,{'R1','R2'},0,...
   [repmat([0 0.4470 0.7410],1,1);repmat([0.8500 0.3250 0.0980],1,1)],p_val,comp) % 
xlabel('Run')
ylabel('Percentage of trials excluded (%)')
box off
%%
save('data.mat','-v7.3')
%% final subjects included
final_sind = find(~isnan(data_nnan(:,1))); %
final_sind(unique(row)) = [];

%% Plot superimposed gaze path - I cannot solve this bug...
sample_rate = data{1,1}.record.sample_rate;
% for ii = final_sind
%     data{ii,jj}
% end
ii = 1;
x_trial_all_mat = []; y_trial_all_mat = []; tarx = []; tary = [];
x_trial_all_flip_mat = []; y_trial_all_flip_mat = [];
for jj = 1:2%:8
% % 1, start
% % 2, fixation
% % 3, 5, 7, 9, targets
% % 10, delay
% % 11, cue
% % 13, iti
% % 14, end

% 1, start
% 2, fixation
% 3, target
% 4, delay
% 5, cue/response
% 6, iti
% 7, end

eye = mod(contains(data{ii,jj}.record.eye,'left')+1,2)+1;
x = data{ii,jj}.samples.x_deg_clean(:,eye); 
y = data{ii,jj}.samples.y_deg_clean(:,eye);

% event start
% when the message start (index)
ev_srt = data{ii,jj}.events.msg.ind_srt; %[1 2 3 5 7 9 10 11 13 14]

% duration of each task period
% not the actual duration - you need to consider the sampling rate
ev_len = diff(ev_srt,1,2);

% mainly focus on the delay period
delay_len = round(ev_len(:,4)/1000)*1000;

% which trials need to fill in the na values
delay_len_add = max(delay_len) - delay_len;

% we want to start a trial 250ms before the target
% 250 ms before target: 1
% target starts: 2
% delay starts: 3
% response starts: 4
% response end: 5
ev_srt_new = ev_srt;
ev_srt_new(:,1) = [];
ev_srt_new(:,1) = ev_srt_new(:,2)-250/1000*sample_rate;
%ev_srt_new(:,end) = [];

% plotted event timing
% 250 ms: start to fixation
% 500 ms: target
% 4000 ms: delay
% 1000 ms: response
% actual timing - do not need to adjust for sampling rate
% /1000: convert to sec
ev_plot = [250 500 4000 1000]/1000;%/1000*sample_rate;%[250 500 500 500 250 4000 1000 750];
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
% why 5: that is when the delay ends
for kk = 1:16
x_trial(:,kk) = [x(ev_srt_new(kk,1):ev_srt_new(kk,4));nan(delay_len_add(kk),1);x((ev_srt_new(kk,4)+1):ev_srt_new(kk,end));nan(max(tr_len)-tr_len(kk),1)];
y_trial(:,kk) = [y(ev_srt_new(kk,1):ev_srt_new(kk,4));nan(delay_len_add(kk),1);y((ev_srt_new(kk,4)+1):ev_srt_new(kk,end));nan(max(tr_len)-tr_len(kk),1)];
end

final_tr =  find(~isnan(data{ii,jj}.cal.primary_sac_err)); % valid trials
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

for jj = 1:2%8
    final_tr =  find(~isnan(data{ii,jj}.cal.primary_sac_err)); % valid trials

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

%% flip x/y and replot gaze path
% xsign = sign(data{1, 1}.param.tarx_deg(1:16));
% ysign = sign(data{1, 1}.param.tary_deg(1:16));
% 
% % x will be positive; y will be all negative
% x_trial_flip = x_trial.*xsign';
% y_trial_flip = y_trial.*(-ysign)';

tm = (1:max(run_len))/sample_rate;%*2/1000;
figure(3);clf
for ii = 1:size(x_trial_all_flip_mat,2)
plot(tm,x_trial_all_flip_mat(:,ii),'Color',[0 0.4470 0.7410],'LineWidth',1)
hold on
plot(tm,y_trial_all_flip_mat(:,ii),'Color',[0.8500 0.3250 0.0980],'LineWidth',1)
hold on
end

%xlim([0 10])
%xlim([0 16])
ylim([-8 8])

for ii = 1:length(ev_plot)-1
line([ev_plot(ii) ev_plot(ii)],[-8 8],'Color','k','LineStyle','--')
hold on
end

%% plot target

figure(1);clf
for jj = 1:2
subplot(1,2,jj)
scatter(data{1,jj}.param.tarx_deg,data{1,jj}.param.tary_deg,5)
hold on
line([-6 6],[0 0],'LineStyle','--')
line([0 0],[-6 6],'LineStyle','--')
%xlim([-6 6])
%ylim([-6 6])
title(num2str(jj))
axis equal
end

% %% together
% figure(2);clf
% for jj = 1:2
% scatter(data{1, jj}.param.datasource{1:16,42}-640,data{1, jj}.param.datasource{1:16,43}-512,20,'LineWidth',2)
% hold on
% end
% line([-512 512],[0 0],'LineStyle','--','LineWidth',2,'Color','k')
% line([0 0],[-512 512],'LineStyle','--','LineWidth',2,'Color','k')
% xlim([-512 512])
% ylim([-512 512])

%% heatmap
% quadrant cue vs. order cue, one subject
task = {'MGS'};
for kk = 1:length(final_sind)
    ii = final_sind(kk);
figure(1);clf

XERR = cell(1,1);
YERR = cell(1,1);
for jj = 1:2
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

cbottom = 0; ctop = .15;
% for pp = 1:2 % two tasks
%     subplot(1,2,pp)
pp = 1;
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
axis equal
saveas(figure(1),[subs_id{ii},'_heatmap.jpg'])
end

%% Heatmap example code
figure(1);clf % set up the figure
cbottom = 0; ctop = .15; % lower bound and upper bound of the colorbar. 
% In other words, the lowest probability density displayed is 0 and the
% highest probability density displayed is 0.15.

xerr = reshape(XERR{pp},[],1); % this is the x error in dva (should be a n x 1 vector)
yerr = reshape(YERR{pp},[],1); % this is the y error in dva

x_values = [-3:0.1:3]; % the window you want to plot. here I only estimated
% and plot errors within plus and minus 3 dva from the target. if you want
% to plot a larger area, e.g., 5 dva, then you will need to change -3 and 3
% to -5 to 5. 0.1 is the step size of the estimation. Smaller step size
% will give you a smoother plot.

% Estimate a continuous pdf from the data
[pdfx xi]= ksdensity(xerr,x_values); % use the ksdensity function to estimate pdf from the data
[pdfy yi]= ksdensity(yerr,x_values); % do it along the x and y dimension separately

% Create 2-d grid of the space you want to estimate.
[xxi,yyi]     = meshgrid(xi,yi);
[pdfxx,pdfyy] = meshgrid(pdfx,pdfy);

% Calculate combined pdf, under assumption of independence
pdfxy = pdfxx.*pdfyy; 

% Plot the results
h = surf(xxi,yyi,pdfxy,'linestyle','none'); % do a surf plot
shading interp % remove the lines
caxis manual % manually set up the color bar, defined below by cbottom and ctop
caxis([cbottom ctop]);
set(gca,'XLim',[-3 3],'XTick',[-3 0 3],'FontSize',14)
set(gca,'YLim',[-3 3],'YTick',[-3 0 3])

% Define the color map. This is my favoriate. You can also use other types
% of colormaps you want.
c=jet(100);
colormap(c(1:100,:));
view(2) % surf gives us a 3d plot, but we want to show a 2d heatmap. this
% command will adjust the angle of the 3d plot so that the final plot looks
% like a 2d heatmap.

% hold on, we want to plot more things on top of the heatmp
hold on
z_max = max(max(get(h,'Zdata')));
% we want to plot each individual datapoints
scatter3(xerr,yerr,z_max*ones(size(xerr)),5,'MarkerEdgeColor','none','MarkerFaceColor',[1 1 1]) 
view(2)

hold on
% we also want to plot the (0,0) point using a cross
h1 = scatter3(0,0,1,700,'+','MarkerEdgeColor','k',...
   'MarkerFaceColor','none','LineWidth',5); %uint8([255 255 255])
colorbar('location','Manual', 'position', [0.93 0.2 0.02 0.6]);
set(gca,'XTick',[],'YTick',[])
axis equal

% save the figure
saveas(figure(1),'heatmap.jpg')
%% aggergate data
%mkdir('cue')
%cd cue
%sb = [1:8 10:12 14:length(subs_id)];

for ss = 1:length(final_sind)%1:size(data,1) % each subject
    ii = final_sind(ss);
p_ord = []; p_quad = []; p_img = [];
p_err = []; a_err = []; n_sac = []; p_rt = []; p_task=[];
p_xend = []; p_yend = []; p_xtar = []; p_ytar = [];

for jj = 1:2 % each run
% task
p_task = [p_task; ones(16,1)];

% % probe_order
% p_ord = [p_ord;data{ii,jj}.param.probe_order(1:16)];

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

% % systematic error
% xend = data{ii,jj}.cal.primary_sac_xend;
% yend = data{ii,jj}.cal.primary_sac_yend;
% xtar = data{ii,jj}.param.tarx_deg(1:16);
% ytar = data{ii,jj}.param.tary_deg(1:16);
% 
% p_xend = [p_xend;xend];
% p_yend = [p_yend;yend];
% p_xtar = [p_xtar;xtar];
% p_ytar = [p_ytar;ytar];

end
stats.p_err(ii,:,:) = p_err;
stats.a_err(ii,:,:) = a_err;
stats.n_sac(ii,:,:) = n_sac;
stats.p_rt(ii,:,:) = p_rt;

% Effects of quadrant
for kk = 1:4
    ind = find(p_quad==kk & p_task==1);
p_err_new(:,kk) = [p_err(ind);nan(8-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(8-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(8-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(8-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
% p_xend_new(:,kk+(hh-1)*4) = [p_xend(ind);nan(16-length(ind),1)];
% p_yend_new(:,kk+(hh-1)*4) = [p_yend(ind);nan(16-length(ind),1)];
% p_xtar_new(:,kk+(hh-1)*4) = [p_xtar(ind);nan(16-length(ind),1)];
% p_ytar_new(:,kk+(hh-1)*4) = [p_ytar(ind);nan(16-length(ind),1)];
end

stats.p_err_quad(ii,:,:) = p_err_new;
stats.a_err_quad(ii,:,:) = a_err_new;
stats.n_sac_quad(ii,:,:) = n_sac_new;
stats.p_rt_quad(ii,:,:) = p_rt_new;
stats.n_tr_quad(ii,:,:) = n_tr;
% stats.p_xend_quad(ii,:,:) = p_xend_new;
% stats.p_yend_quad(ii,:,:) = p_yend_new;
% stats.p_xtar_quad(ii,:,:) = p_xtar_new;
% stats.p_ytar_quad(ii,:,:) = p_ytar_new;
% [stats.p_sys_quad(ii,:),stats.p_unsys_quad(ii,:)] = cal_sys_unsys(p_xend_new,p_yend_new,p_xtar_new,p_ytar_new);

% Effects of image category
for kk = 1:4
    ind = find(p_img==kk);
p_err_new(:,kk) = [p_err(ind);nan(8-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(8-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(8-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(8-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
% p_xend_new(:,kk+(hh-1)*4) = [p_xend(ind);nan(16-length(ind),1)];
% p_yend_new(:,kk+(hh-1)*4) = [p_yend(ind);nan(16-length(ind),1)];
% p_xtar_new(:,kk+(hh-1)*4) = [p_xtar(ind);nan(16-length(ind),1)];
% p_ytar_new(:,kk+(hh-1)*4) = [p_ytar(ind);nan(16-length(ind),1)];
end
stats.p_err_img(ii,:,:) = p_err_new;
stats.a_err_img(ii,:,:) = a_err_new;
stats.n_sac_img(ii,:,:) = n_sac_new;
stats.p_rt_img(ii,:,:) = p_rt_new;
stats.n_tr_img(ii,:,:) = n_tr;
% stats.p_xend_img(ii,:,:) = p_xend_new;
% stats.p_yend_img(ii,:,:) = p_yend_new;
% stats.p_xtar_img(ii,:,:) = p_xtar_new;
% stats.p_ytar_img(ii,:,:) = p_ytar_new;
% [stats.p_sys_img(ii,:),stats.p_unsys_img(ii,:)] = cal_sys_unsys(p_xend_new,p_yend_new,p_xtar_new,p_ytar_new);
end

fn = fieldnames(stats);
for k=1:numel(fn)
    stats.(fn{k})(stats.(fn{k}) == 0) = nan;
end

save('stats.mat','stats')

%% plot histogram
figure(2);clf
hist(reshape(stats.p_err,[],1))

figure(3);clf
hist(reshape(stats.p_rt,[],1))

%% check effects of different quadrants/images - Group analysis
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_quad,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Quadrant',{'First','Second','Third','Fourth'});

p = Mrm{[1:3,5:6,9],5};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3]};
p_val = p(p <= 0.05); %p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); %comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q1','Q2','Q3','Q4'},0,...
   repmat([0 0.4470 0.7410],4,1),p_val,comp) % repmat([0.8500 0.3250 0.0980],4,1)]

xlabel('Quadrant')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_quad.jpg')
writematrix(temp,'pse_quad.csv')
%%
% rt
temp = squeeze(nanmean(stats.p_rt_quad,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Quadrant',{'First','Second','Third','Fourth'});

p = Mrm{[1:3,5:6,9],5};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3]};
p_val = p(p <= 0.05); %p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); %comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'Q1','Q2','Q3','Q4'},0,...
   repmat([0 0.4470 0.7410],4,1),p_val,comp) % repmat([0.8500 0.3250 0.0980],4,1)]

xlabel('Quadrant')
ylabel('Latency (ms)')
saveas(figure(1),'pse_quad_rt.jpg')
writematrix(temp,'pse_quad_rt.csv')

%% image
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_img,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Image',{'F Face', 'M Face', 'House 1', 'House 2'});

p = Mrm{[1:3,5:6,9],5};
comp_all = {[1 3],[1 4],[1 2],[3 4],[3 2],[2 4]};
p_val = p(p <= 0.05); %p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); %comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'F Face', 'M Face', 'House 1', 'House 2'},0,...
   repmat([0 0.4470 0.7410],4,1),p_val,comp) % repmat([0.8500 0.3250 0.0980],4,1)]

xlabel('Image')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_img.jpg')
writematrix(temp,'pse_img.csv')
%%
% rt
temp = squeeze(nanmean(stats.p_rt_img,2));
[ranovatbl,Mrm,mau,eps] = nWayRM(temp,'Image',{'F Face', 'M Face', 'House 1', 'House 2'});

p = Mrm{[1:3,5:6,9],5};
comp_all = {[1 3],[1 4],[1 2],[3 4],[3 2],[2 4]};
p_val = p(p <= 0.05); %p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); %comp = [comp,{[2.5 6.5]}];

figure(1);clf
boxWithDots3(temp,{'F Face', 'M Face', 'House 1', 'House 2'},0,...
   repmat([0 0.4470 0.7410],4,1),p_val,comp) % repmat([0.8500 0.3250 0.0980],4,1)]

xlabel('Image')
ylabel('Latency (ms)')
saveas(figure(1),'pse_img_rt.jpg')
writematrix(temp,'pse_img_rt.csv')



% start from here, need to modify
%% run 1-4, quadrant cue, for each subject
mkdir('quadrant_cue')
cd quadrant_cue
sb = [1:8 10:12 14:29];

for ii = sb%1:size(data,1) % each subject
p_ord = []; p_quad = []; p_img = [];
p_err = []; a_err = []; n_sac = []; p_rt = [];

for jj = 1:4 % each run
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
end

% Effects of encoding order
for kk = 1:4
    ind = find(p_ord==kk);
p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
end

stats.p_err_ord(ii,:,:) = p_err_new;
stats.a_err_ord(ii,:,:) = a_err_new;
stats.n_sac_ord(ii,:,:) = n_sac_new;
stats.p_rt_ord(ii,:,:) = p_rt_new;
stats.n_tr_ord(ii,:,:) = n_tr;

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[subs_id{ii},'_pse_order.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[subs_id{ii},'_sse_order.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[subs_id{ii},'_nsac_order.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Latency (ms)')
saveas(figure(4),[subs_id{ii},'_rt_order.jpg']);

% Effects of quadrant
for kk = 1:4
    ind = find(p_quad==kk);
p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
end

stats.p_err_quad(ii,:,:) = p_err_new;
stats.a_err_quad(ii,:,:) = a_err_new;
stats.n_sac_quad(ii,:,:) = n_sac_new;
stats.p_rt_quad(ii,:,:) = p_rt_new;
stats.n_tr_quad(ii,:,:) = n_tr;

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[subs_id{ii},'_pse_quad.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[subs_id{ii},'_sse_quad.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[subs_id{ii},'_nsac_quad.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Latency (ms)')
saveas(figure(4),[subs_id{ii},'_rt_quad.jpg']);

% Effects of image category

for kk = 1:4
    ind = find(p_img==kk);
p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
end

stats.p_err_img(ii,:,:) = p_err_new;
stats.a_err_img(ii,:,:) = a_err_new;
stats.n_sac_img(ii,:,:) = n_sac_new;
stats.p_rt_img(ii,:,:) = p_rt_new;
stats.n_tr_img(ii,:,:) = n_tr;

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[subs_id{ii},'_pse_img.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[subs_id{ii},'_sse_img.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[subs_id{ii},'_nsac_img.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Latency (ms)')
saveas(figure(4),[subs_id{ii},'_rt_img.jpg']);

end

fn = fieldnames(stats);
for k=1:numel(fn)
    stats.(fn{k})(stats.(fn{k}) == 0) = nan;
end

save('quad.mat','stats')
    
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

p = Mrm.two{[1:3,5:6,9],5};
comp_all = {[1 4],[1 2],[1 3],[4 2],[4 3],[2 3]};
p_val = p(p <= 0.05); p_val = [p_val;Mrm.one{1,5}];
comp = comp_all(p <= 0.05); comp = [comp,{[2.5 6.5]}];

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

p = Mrm.two{[1:3,5:6,9],5};
comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
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

p = Mrm.two{[1:3,5:6,9],5};
comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
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

p = Mrm.two{[1:3,5:6,9],5};
comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
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

p = Mrm.two{[1:3,5:6,9],5};
comp_all = {[1 2],[1 3],[1 4],[2 3],[2 4],[3 4]};
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
%% most accurate saccade error
% mean
temp = squeeze(nanmean(stats.a_err_ord,2));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Mean Smallest Saccade Error (dva)')
saveas(figure(1),'ase_ord.jpg')

% standard deviation
temp = squeeze(std(stats.a_err_ord,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('STDEV Smallest Saccade Error (dva)')
saveas(figure(1),'ase_ord_std.jpg')

%% quadrant effect
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_quad,2));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
xlabel('Quadrant')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_quad.jpg')

% standard deviation
temp = squeeze(std(stats.p_err_quad,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
xlabel('Quadrant')
ylabel('STDEV Primary Saccade Error (dva)')
saveas(figure(1),'pse_quad_std.jpg')

% rt
temp = squeeze(mean(stats.p_rt_quad,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
xlabel('Quadrant')
ylabel('Mean Latency (ms)')
saveas(figure(1),'pse_quad_rt.jpg')
%% image effect
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_img,2));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_img.jpg')

% standard deviation
temp = squeeze(std(stats.p_err_img,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('STDEV Primary Saccade Error (dva)')
saveas(figure(1),'pse_img_std.jpg')

% rt
temp = squeeze(mean(stats.p_rt_img,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Mean Latency (ms)')
saveas(figure(1),'pse_img_rt.jpg')

%% run 5-8, order cue, for each subject
mkdir('order_cue')
cd order_cue
for ii = 14:18%1:size(data,1) % each subject
p_ord = []; p_quad = []; p_img = [];
p_err = []; a_err = []; n_sac = []; p_rt = [];

for jj = 5:8 % each run
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
end

% Effects of encoding order
for kk = 1:4
    ind = find(p_ord==kk);
p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
end

stats.p_err_ord(ii,:,:) = p_err_new;
stats.a_err_ord(ii,:,:) = a_err_new;
stats.n_sac_ord(ii,:,:) = n_sac_new;
stats.p_rt_ord(ii,:,:) = p_rt_new;
stats.n_tr_ord(ii,:,:) = n_tr;

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[subs_id{ii},'_pse_order.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[subs_id{ii},'_sse_order.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[subs_id{ii},'_nsac_order.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Latency (ms)')
saveas(figure(4),[subs_id{ii},'_rt_order.jpg']);

% Effects of quadrant
for kk = 1:4
    ind = find(p_quad==kk);
p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
end

stats.p_err_quad(ii,:,:) = p_err_new;
stats.a_err_quad(ii,:,:) = a_err_new;
stats.n_sac_quad(ii,:,:) = n_sac_new;
stats.p_rt_quad(ii,:,:) = p_rt_new;
stats.n_tr_quad(ii,:,:) = n_tr;

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[subs_id{ii},'_pse_quad.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[subs_id{ii},'_sse_quad.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[subs_id{ii},'_nsac_quad.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Quadrant')
ylabel('Latency (ms)')
saveas(figure(4),[subs_id{ii},'_rt_quad.jpg']);

% Effects of image category

for kk = 1:4
    ind = find(p_img==kk);
p_err_new(:,kk) = [p_err(ind);nan(16-length(ind),1)];
a_err_new(:,kk) = [a_err(ind);nan(16-length(ind),1)];
n_sac_new(:,kk) = [n_sac(ind);nan(16-length(ind),1)];
p_rt_new(:,kk) = [p_rt(ind);nan(16-length(ind),1)];
n_tr(1,kk) = sum(~isnan(p_err(ind)));
end

stats.p_err_img(ii,:,:) = p_err_new;
stats.a_err_img(ii,:,:) = a_err_new;
stats.n_sac_img(ii,:,:) = n_sac_new;
stats.p_rt_img(ii,:,:) = p_rt_new;
stats.n_tr_img(ii,:,:) = n_tr;

% Plot
figure(1);clf
boxWithDots2(p_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Primary Saccade Error (dva)')
saveas(figure(1),[subs_id{ii},'_pse_img.jpg']);

figure(2);clf
boxWithDots2(a_err_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Smallest Saccade Error (dva)')
saveas(figure(2),[subs_id{ii},'_sse_img.jpg']);

figure(3);clf
boxWithDots2(n_sac_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Number of Saccades <= 3.5 dva')
saveas(figure(3),[subs_id{ii},'_nsac_img.jpg']);

figure(4);clf
boxWithDots2(p_rt_new,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Latency (ms)')
saveas(figure(4),[subs_id{ii},'_rt_img.jpg']);

end

fn = fieldnames(stats);
for k=1:numel(fn)
    stats.(fn{k})(stats.(fn{k}) == 0) = nan;
end

save('order.mat','stats')
%% Group analysis
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_ord,2));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_ord.jpg')

% standard deviation
temp = squeeze(std(stats.p_err_ord,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('STDEV Primary Saccade Error (dva)')
saveas(figure(1),'pse_ord_std.jpg')

% rt
temp = squeeze(std(stats.p_rt_ord,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Latency (ms)')
saveas(figure(1),'pse_ord_rt.jpg')

%% most accurate saccade error
% mean
temp = squeeze(nanmean(stats.a_err_ord,2));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'ase_ord.jpg')

% standard deviation
temp = squeeze(std(stats.a_err_ord,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('STDEV Primary Saccade Error (dva)')
saveas(figure(1),'ase_ord_std.jpg')

% rt
temp = squeeze(mean(stats.p_rt_ord,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'1ST', '2ND', '3RD', '4TH'},[],[])
xlabel('Encoding Order')
ylabel('Mean Latency (ms)')
saveas(figure(1),'pse_ord_rt.jpg')
%% quadrant effect
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_quad,2));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
xlabel('Quadrant')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_quad.jpg')

% standard deviation
temp = squeeze(std(stats.p_err_quad,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
xlabel('Quadrant')
ylabel('STDEV Primary Saccade Error (dva)')
saveas(figure(1),'pse_quad_std.jpg')

% rt
temp = squeeze(mean(stats.p_rt_quad,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'URV', 'ULV', 'LLV', 'LRV'},[],[])
xlabel('Quadrant')
ylabel('Mean Latency (ms)')
saveas(figure(1),'pse_quad_rt.jpg')
%% image effect
% primary saccade error
% mean
temp = squeeze(nanmean(stats.p_err_img,2));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Mean Primary Saccade Error (dva)')
saveas(figure(1),'pse_img.jpg')

% standard deviation
temp = squeeze(std(stats.p_err_img,0,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('STDEV Primary Saccade Error (dva)')
saveas(figure(1),'pse_img_std.jpg')

% rt
temp = squeeze(mean(stats.p_rt_img,2,"omitnan"));
[ranovatbl,Mrm,mau] = nWayRM(temp,'order',{'1ST', '2ND', '3RD', '4TH'});

figure(1);clf
boxWithDots2(temp,{'F Face', 'M Face', 'House 1', 'House 2'},[],[])
xlabel('Image')
ylabel('Mean Latency (ms)')
saveas(figure(1),'pse_img_rt.jpg')

