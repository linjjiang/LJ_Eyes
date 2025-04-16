function [blink_onset,blink_offset,blink_onset_time,blink_offset_time,nblink] = detect_blink_vel(edf,set)
% Detects and removes un-physiological movement using the velocity and
% acceleration threshold
% 1000

% take the pupil size
pupil_smooth = edf.samples.pupil_size(:,set.eye);
% sample_window = 1/edf.record.sample_rate; %2ms i.e., 500Hz tracking
% 
% % we would first like to smooth the pupil time series
% ms_4_smooting  = 10;                                    % using a gap of 10 ms for the smoothing
% samples2smooth = ceil(ms_4_smooting/edf.record.sample_rate); % amount of samples to smooth 
% pupil_smooth    = smoothdata(pupil_data, samples2smooth);    
% pupil_smooth(pupil_smooth==0) = nan;                      % replace zeros with NaN values      
% % 
% % calculate velocity of the pupil
% pupil_vel = zeros(size(pupil_smooth));
% for ii = 3:(size(pupil_smooth, 1) - 2) % 2 additional samples chopped off either end
%     pupil_vel(ii) = (pupil_smooth(ii + 2) + pupil_smooth(ii + 1) - pupil_smooth(ii - 1) - pupil_smooth(ii - 2))/(6*sample_window);
% end

pupil_vel = edf.samples.velp(:,set.eye);

% pupil velocity thresholds
V_threshold = set.noise.blink_pvel;% mad(pupil_vel,1)*3;% 

% Detect possible blinks and noise (where there is no pupil data or if the pupil size changes too fast)
blinkIdx = (abs(pupil_vel) > V_threshold | isnan(pupil_smooth));

blinkIdx_final = zeros(size(pupil_vel));
blinkIdx_final(blinkIdx) = 1;

% Label blinks or noise
blinkLabeled = bwlabel(blinkIdx);

% We would like to extend the blink windows
blink_extend = ceil(set.noise.blink_extend/(1000/edf.record.sample_rate));

% % Initiate blink/noise onset and offset
% blink_onset = [];
% blink_offset = [];
% blink_idx = 1;
% % Let's go through each sample
% for k = 2:length(pupil_vel)
%     if abs(pupil_vel(k)) <= V_threshold & ~isnan(pupil_vel(k))
%         continue;
%     elseif (isnan(pupil_vel(k)) & ~isnan(pupil_vel(k-1))) | ... % first time the pupil data becomes NAN
%             pupil_vel(k) <= -V_threshold & pupil_vel(k) > V_threshold % or first time the velocity drops below a negative threshold
%         blink_onset = [blink_onset;k];
%     elseif (
% end
    % The onset of the blink is detected as the moment at which the
    % velocity drops below a negative threshold -V_threshold

    
    % The reversal period of a blinked is the moment at which the velocity
    % exceeds a positive threshold
    
    % The offset is detected as the moment at which the velocity drops back
    % to 0.
    
blink_onset = []; blink_offset = [];
% Process one blink or noise period at the time
for k = 1:max(blinkLabeled)

    % The samples related to the current event
    b = find(blinkLabeled == k);
       
    % Go back in time to see where the blink (noise) started
    sEventIdx = find(pupil_vel(b(1):-1:1) <= V_threshold);
    if isempty(sEventIdx)
        sEventIdx = b(1);
    else
       sEventIdx = b(1) - sEventIdx(1) + 1;
    end
    % we would like to further remove 100 ms before the the detected blink
    % onset
    if sEventIdx - blink_extend <= 0 
       sEventIdx = 1;
    else
    sEventIdx = sEventIdx-blink_extend;
    end
     blinkIdx_final(sEventIdx:b(1)) = 1;   
    
    % Go forward in time to see where the blink (noise) ended    
    eEventIdx = find(pupil_vel(b(end):end) <= V_threshold);
    if isempty(eEventIdx)
        eEventIdx = b(end);
    else
        eEventIdx = (b(end) + eEventIdx(1) - 1);
    end
    
    if eEventIdx + blink_extend >= length(pupil_vel)
        eEventIdx = length(blinkIdx_final); 
    else
eEventIdx = eEventIdx+blink_extend;
    end
        blinkIdx_final(b(end):eEventIdx) = 1;    
    
    blink_onset = [blink_onset;sEventIdx];
    blink_offset = [blink_offset;eEventIdx];
end

blink_onset_time = edf.samples.time(blink_onset);
blink_offset_time = edf.samples.time(blink_offset);

nblink = length(blink_onset);


% blink_idx = find(blinkIdx_final == 1 & edf.samples.trial == 1);
% pupil_tr = pupil_smooth(edf.samples.trial == 1);
% pupil_blink = pupil_smooth(blinkIdx_final == 1 & edf.samples.trial == 1);
% figure;
% plot(pupil_tr)
% hold on
% scatter(blink_idx,pupil_blink,1)

% % Set possible blink and noise index to '1'
% ETparams.nanIdx(i,j).Idx(blinkIdx) = 1;   

% temp_idx = find(ETparams.nanIdx(i,j).Idx);
% if length(temp_idx)/length(V) > 0.20
%     disp('Warning: This trial contains > 20 % noise+blinks samples')
%     ETparams.data(i,j).NoiseTrial = 0;
% else
%     ETparams.data(i,j).NoiseTrial = 1;
% end
% ETparams.data(i,j).vel(temp_idx) = nan;
% ETparams.data(i,j).acc(temp_idx) = nan;
% ETparams.data(i,j).X(temp_idx) = nan;
% ETparams.data(i,j).Y(temp_idx) = nan;


