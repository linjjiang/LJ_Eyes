function plot_gaze_screen_mgs(edf,final_tr)

sample_rate = edf.record.sample_rate;
eye = mod(contains(edf.record.eye,'left')+1,2)+1;
x = edf.samples.x_deg_clean(:,eye);
y = edf.samples.y_deg_clean(:,eye);

% event start
% when the message start (index)
ev_srt = edf.events.msg.ind_srt;

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

% plotted event timing
% 250 ms: start to fixation
% 500 ms: target
% 4000 ms: delay
% 1000 ms: response
% actual timing - do not need to adjust for sampling rate
% /1000: convert to sec
ev_plot = [250 500 4000 1000]/1000;
ev_plot = cumsum(ev_plot);

% max trial length
tr_len = ev_srt_new(:,end)-ev_srt_new(:,1)+1+delay_len_add;

% get the samples trial by trial
clear x_trial y_trial
% why 5: that is when the delay ends
for kk = 1:16
    x_trial(:,kk) = [x(ev_srt_new(kk,1):ev_srt_new(kk,4));nan(delay_len_add(kk),1);x((ev_srt_new(kk,4)+1):ev_srt_new(kk,end));nan(max(tr_len)-tr_len(kk),1)];
    y_trial(:,kk) = [y(ev_srt_new(kk,1):ev_srt_new(kk,4));nan(delay_len_add(kk),1);y((ev_srt_new(kk,4)+1):ev_srt_new(kk,end));nan(max(tr_len)-tr_len(kk),1)];
end

x_trial_all = x_trial(:,final_tr); % only select subset of trials
y_trial_all = y_trial(:,final_tr);
run_len = size(x_trial,1);

tarx = edf.param.tarx_deg(final_tr)';
tary = edf.param.tary_deg(final_tr)';

xsign = sign(edf.param.tarx_deg(final_tr));
ysign = sign(edf.param.tary_deg(final_tr));

% x will be positive; y will be all negative
x_trial_all_flip = x_trial_all.*xsign';
y_trial_all_flip= y_trial_all.*(-ysign)';

x_trial_all_mat = x_trial_all;
y_trial_all_mat = y_trial_all;
x_trial_all_flip_mat = x_trial_all_flip;
y_trial_all_flip_mat = y_trial_all_flip;

% plot
figure(1);clf
h = plot(x_trial_all_mat,y_trial_all_mat)
xlim([-6 6])
ylim([-6 6])
hold on
scatter(tarx,tary,30,'k','+')
box off
axis equal

end