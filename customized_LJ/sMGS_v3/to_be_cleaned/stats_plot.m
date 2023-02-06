%% Step 8 Statistical analysis and plotting

clear all
clc

% append data across runs
data_dir = 'C:\Users\lj104\Documents\Linjing_Research\thesis_data\images\Behavior\Behav_v3_long\sMGS\';

% We want to process each data folder separately
file_dirs = dir([data_dir 'run*\p*']);

%%
clear subs runs
for ii = 1:length(file_dirs)
    subs{ii} = file_dirs(ii).name;
    runs(ii) = str2num(erase(file_dirs(ii).folder,[data_dir 'run']));
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

%%
save('C:\Users\lj104\Documents\Linjing_Research\thesis_data\images\Analysis\Behavior\v3_long\sMGS\analysis_0906.mat')
%% for each subject
for ii = 1:size(data,1) % each subject
p_ord = []; p_quad = []; p_img = [];
p_err = []; a_err = []; n_sac = []; p_rt = [];

for jj = 1:size(data,2) % each run
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

%% Effects of encoding order
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

%% Effects of quadrant
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

%% Effects of image category

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
    
%% Plotting each trial
for ii = 1:size(data,1) % each subject
jj = 1; % run 1
tt = 10; % trial 5
edf = data{ii,jj};
set = data_set{ii,jj};

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
title(['Gaze time course: trial ',num2str(tt),' sub ',subs_id{ii},' run',num2str(jj)])
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
saveas(figure(1),[subs_id{ii},'_run',num2str(jj),'_trial',num2str(tt),'_gaze.jpg']);

end

% for jj = 1:4   
% line([tm(ind(1)),tm(ind(end))],[edf.param.tarx_deg(ii,jj) edf.param.tarx_deg(ii,jj)],'LineStyle','--','Color',[0, 0.4470, 0.7410]);
% line([tm(ind(1)),tm(ind(end))],[edf.param.tary_deg(ii,jj) edf.param.tary_deg(ii,jj)],'LineStyle','--','Color',[0.8500, 0.3250, 0.0980]);
% text(tm(ind(end))*0.9,edf.param.tarx_deg(ii,jj)*1,0,num2str(jj),"Color",[0, 0.4470, 0.7410]);
% text(tm(ind(end))*0.9,edf.param.tary_deg(ii,jj)*1,0,num2str(jj),"Color",[0.8500, 0.3250, 0.0980]);
% hold on
% end

%% Data quality
for ii = 1:length(subs_id)
    for jj = 1:length(runs_id)
        perc(ii,jj) = data{ii,jj}.trackloss.perc;
        nblink(ii,jj) = data{ii,jj}.blink.num;
        nnan(ii,jj) = data{ii,jj}.cal.num_nan;
    end
end
perc_mean = mean(perc,2);
nblink_mean = mean(nblink,2)/16;
nnan_all = sum(nnan,2);
tbl = table(subs_id',perc_mean,nblink_mean,nnan_all,'VariableNames',{'ID','% Sample Loss','Avg. No. Blinks Per Trial','No. Trials Excluded'});
writetable(tbl,'data_quality.csv')
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
