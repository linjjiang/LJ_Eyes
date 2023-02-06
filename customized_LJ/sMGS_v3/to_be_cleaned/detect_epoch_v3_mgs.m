function edf = detect_epoch_v3_mgs(edf,set)
% Detect the onset and offset of a trial-related message
% Including the start and end of a trial
% And the start and end of a task epoch

msg = set.msg; % prototype messages in a trial
msgText = []; % actual content of the message, from 1 - N
msgTime = []; % timing of the message

for ii = 1:length(msg) % for each message
    ind = [];
    ind = contains(edf.default_events.Messages.info,msg{ii}); % startsWith
    ind = find(ind==1);
    if ii == 1|ii == length(msg) % start and end
        ind(end) = [];
    end
    msgText = [msgText;ii*ones(length(ind),1)];
    msgTime = [msgTime;edf.default_events.Messages.time(ind)'];
end

% find out how many trials are there
ntr = sum(msgText==1);
% if ntr*length(msg) ~= length(msgText) % if the number of messages doesn't match
%     error('Missing messages!!')
% end
edf.samples.ntrial = ntr;

% if there is only one message (which means, somehow our experiment doesn't
% have all the messages), we need to add all the other messages ourselves
% based on the approximate timing of each trial
if length(msg) <= 1
% First see how many task periods
n_epoch = size(edf.param.time,2); 
for ii = 1:ntr % for each trial
    for jj = 2:n_epoch % for each epoch
    msgText(ii,jj) = jj;
    msgTime(ii,jj) = msgTime(ii,jj-1) + edf.param.time(ii,jj-1);
    end
end
end

% Let's store the onset and offset of each trial and epoch separately
edf.events.num_trial = ntr;
edf.events.msg.txt= reshape(msgText,ntr,[]);
edf.events.msg.time = reshape(msgTime,ntr,[]);

% onset and offset of a trial
msgTime = edf.events.msg.time;
msgText = edf.events.msg.txt;
for ii = 1:ntr
for jj = 1:size(msgText,2)
[val,ind] = min(abs(edf.samples.time-msgTime(ii,jj)));
edf.events.msg.ind_srt(ii,jj) = ind(1);
if size(msgText,2) > 1 % more than 1 message
if jj == 1 % the first message (e.g., start of a trial)
    if ii == 1 % the first trial
        edf.events.msg.ind_end(ii,jj) = nan;
    else % not the first trial
    edf.events.msg.ind_end(ii-1,size(msgText,2)) = ind(1); % end of the last message, last trial
    end
else % not the first message
    if ii == ntr & jj == size(msgText,2) % the last message and the last trial
edf.events.msg.ind_end(ii,jj) = length(edf.samples.time); % last time point
    else
edf.events.msg.ind_end(ii,jj-1) = ind(1); % end of the last epoch in the same trial
    end
end
elseif size(msgText,2) == 1 % only has 1 message
        if ii == 1 % the first trial
        edf.events.msg.ind_end(ii,jj) = nan;
        elseif ii == ntr % the last trial
            edf.events.msg.ind_end(ii,jj) = length(edf.samples.time); % last time point
        else % in between
           edf.events.msg.ind_end(ii-1,jj) = ind(1); 
        end
end

end
end

% store trial and epoch info in edf.samples
edf.samples.trial = zeros(size(edf.samples.time));
edf.samples.msg = edf.samples.trial;
for ii = 1:ntr
edf.samples.trial(edf.events.msg.ind_srt(ii,1):edf.events.msg.ind_end(ii,size(msgText,2))) = ii;
for jj = 1:size(msgText,2)
    edf.samples.msg(edf.events.msg.ind_srt(ii,jj):edf.events.msg.ind_end(ii,jj)) = jj;
end
end

