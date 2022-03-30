function [onset_ind,offset_ind,onset_time,offset_time,nblink] = detect_blink_basic(edf,set)
% based on eyelink blink parsing program
% methods 1

onset_time = edf.default_events.Eblink.start';
offset_time = edf.default_events.Eblink.end';

% get the id of the blink onset
[a,onset_ind] = ismember(onset_time,edf.samples.time);
[b,offset_ind] = ismember(offset_time,edf.samples.time);

% if we can't find the onset/offset time in the time stamp
if ~all(a)
    onset = onset_time(~a); % get those onset times
    for ii = 1:length(onset)
        [~,temp] = min(abs(onset(ii)-edf.samples.time)); % find the index of the closest time stamp
        onset_closest(ii) = temp(1);
    end
    onset_ind(~a) = onset_closest; % assign the index to the onset index
    onset_time(~a) = edf.samples.time(onset_closest); % assign the closest time to the original onset time
end

% same for offset time
if ~all(b)
    offset = offset_time(~b); % get those onset times
    for ii = 1:length(offset)
        [~,offset,temp] = min(abs(offset(ii)-edf.samples.time)); % find the index of the closest time stamp
    offset_closest(ii) = temp(1);
    end
    offset_ind(~b) = offset_closest; % assign the index to the onset index
    offset_time(~b) = edf.samples.time(offset_closest); % assign the closest time to the original onset time
end

% number of blinks
nblink = length(onset_ind);
end

