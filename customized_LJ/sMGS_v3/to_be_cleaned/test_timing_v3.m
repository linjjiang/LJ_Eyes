function edf = test_timing_v3(edf)
% Test the timing of our fMRI experiment

% scan start time
ind = contains(edf.default_events.Messages.info,'TTL_pulse_received'); % startsWith
scan_srt_tm = edf.default_events.Messages.time(ind);

% trial srt
% First trial and last trial
ind1 = contains(edf.default_events.Messages.info,'TRIALID');
ind2 = contains(edf.default_events.Messages.info,'TRIAL_RESULT');
%edf.default_events.Messages.info(ind1)
%edf.default_events.Messages.info(ind2)

% trial start time and end time - all trials including baseline
tr_srt_tm = edf.default_events.Messages.time(ind1)'; tr_srt_tm(1) = scan_srt_tm; 
tr_end_tm = edf.default_events.Messages.time(ind2)';

% time of each epoch - only middle 16 trials
tr_epoch_tm = edf.events.msg.time(:,2:14);

% calculate the differences
% 1. trial duration
tr_dur = tr_end_tm - tr_srt_tm;
% 2. epoch duration
epoch_dur = diff(tr_epoch_tm,1,2);

% get the planned timing for each epoch
epoch_dur_plan = edf.param.time(2:17,:);
epoch_dur_plan(:,2:8) = [epoch_dur_plan(:,2) epoch_dur_plan(:,6) epoch_dur_plan(:,3) epoch_dur_plan(:,7)...
    epoch_dur_plan(:,4) epoch_dur_plan(:,8) epoch_dur_plan(:,5)];

% get the planned timing for the whole trial
tr_dur_plan = [990*6;sum(epoch_dur_plan,2);990*20];

% differences in trial duration
tr_dur_diff = tr_dur - tr_dur_plan;

% differences in epoch during
epoch_dur_diff = epoch_dur - epoch_dur_plan;

% from trial start to fixation
srt_dur_diff = diff(edf.events.msg.time(:,1:2),1,2);

% differences in epoch - including from start to fixation
epoch_dur_diff = [srt_dur_diff epoch_dur_diff];

% store the values to edf structure
edf.timing.epoch_dur_diff = epoch_dur_diff;
edf.timing.tr_dur_diff = tr_dur_diff;

end