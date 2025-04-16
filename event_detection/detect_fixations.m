function edf = detect_fixations(edf,set)
% Detect fixations in the samples based on the criteria set in "settings"
% We need to run the fixcade detection first before running fixation
% detection function
% Dispersion-based fixation detection (I-DT, Reviewed in Salvucci & Goldberg, 
% 2000; Widdle 1984)
% fixations are defined as samples with a velocity lower than or equal to 
% 10 dva/s, duration longer than or equal to 30 ms, and both horizontal and 
% vertical gaze dispersion smaller than or equal to 1.5 dva

% By: Linjing Jiang

vel = edf.samples.vel_deg_clean(:,set.eye);
acc = edf.samples.acc_deg_clean(:,set.eye);

xPos = edf.samples.x_deg_clean(:,set.eye);
yPos = edf.samples.y_deg_clean(:,set.eye);
xPos_pix = edf.samples.x_clean(:,set.eye);
yPos_pix = edf.samples.y_clean(:,set.eye);

% % we would like to smooth the x and y position data to get a better
% % fixation detection performance
% % Lowpass filter window length
% smoothInt = 20/1000; % in seconds
% % Span of filter
% span = ceil(smoothInt*edf.record.sample_rate);
% % Construct the filter
% %--------------------------------------------------------------------------
% N = 2;                 % Order of polynomial fit
% F = 2*ceil(span)-1;    % Window length
% [b,g] = sgolay(N,F);   % Calculate S-G coefficients
% 
% % smoothing
% xPos = conv(xPos,g(:,1), 'same');
% yPos = conv(yPos,g(:,1), 'same');
% xPos_pix = conv(xPos_pix,g(:,1), 'same');
% yPos_pix = conv(yPos_pix,g(:,1), 'same');
% 

% number of trials
ntr = edf.samples.ntrial;

% fixation thresholds
disp_th = set.fix.disp_threshold; % dispersion threshold for fixation
dur_th = set.fix.dur_threshold; % duration threshold for fixation
vel_th = set.fix.vel_threshold; % velocity threshold for fixation

% fixation detection
% preallocate memory
edf.events.fix.trial = [];
edf.events.fix.msg_srt = [];
edf.events.fix.msg_end = [];
edf.events.fix.ind_srt = [];
edf.events.fix.ind_end = [];
edf.events.fix.x_srt = [];
edf.events.fix.y_srt = [];
edf.events.fix.x_end = [];
edf.events.fix.y_end = [];
edf.events.fix.x_srt_pix = [];
edf.events.fix.y_srt_pix = [];
edf.events.fix.x_end_pix = [];
edf.events.fix.y_end_pix = [];
edf.events.fix.xdisp = [];
edf.events.fix.ydisp = [];
edf.events.fix.peak_vel = [];
edf.events.fix.avg_vel = [];
edf.events.fix.peak_acc = [];
edf.events.fix.dur = [];
edf.events.fix.artifact = [];
edf.samples.is_fixation = zeros(size(edf.samples.time));

%% first exclude samples that resemble saccade but with a lower velocity threshold
% (those did not pick up by our saccade detection algorithm)

edf.samples.is_saccade_lower = zeros(size(edf.samples.time)); % does this sample belong to a saccade
edf.samples.is_saccade_lower(vel >= vel_th) = 1;

%%
for ii = 1:ntr % for each trial
    % find candidate samples that is not a saccade
    candidates = find(edf.samples.is_saccade_lower == 0 & edf.samples.trial == ii & edf.samples.is_artifact == 0);
    if candidates
        % check for multiple candidate fixations in single
        % trial, using threshold parameters defined at top
        fixations = [];
        diffCandidates = diff(candidates);
        breaks = [0;find(diffCandidates > 1);size(candidates, 1)];
        for jj = 1:(size(breaks, 1) - 1) % for each fixation

            % find individual candidate fxiations
            fixations = [candidates(breaks(jj) + 1) candidates(breaks(jj + 1))];

            % exceeds dispersion threshold?
            xsamples = xPos(fixations(1):fixations(2));
            ysamples = yPos(fixations(1):fixations(2));

            if (max(xsamples)-min(xsamples) <= disp_th) & (max(ysamples)-min(ysamples) <= disp_th)

                    % exceeds duration threshold?
                    dur = (fixations(2) - fixations(1))*1000/edf.record.sample_rate;

                    if dur >= dur_th
                        % store fixation information
                        peakVelocity = max(vel(fixations(1):fixations(2)));
                        avgVelocity = mean(vel(fixations(1):fixations(2)));

                        % What task epoch this fixcade belongs to
                        % fixcade onset
                        epoch_on = edf.samples.msg(fixations(1));
                        % fixcade offset
                        epoch_off = edf.samples.msg(fixations(2));

                        % Whether this fixation is near an artifact (within 25
                        % ms)
                        span = ceil(50/1000*edf.record.sample_rate);
                        if (fixations(1) - span) <= 0
                        art = any(isnan(edf.samples.x_deg_clean(1):(fixations(2) + span)));
                        else
                        art = any(isnan(edf.samples.x_deg_clean(fixations(1) - span):(fixations(2) + span)));
                        end

                        % store fixcade info
                        edf.events.fix.trial = [edf.events.fix.trial;ii];
                        edf.events.fix.msg_srt = [edf.events.fix.msg_srt;epoch_on];
                        edf.events.fix.msg_end = [edf.events.fix.msg_end;epoch_off];
                        edf.events.fix.ind_srt = [edf.events.fix.ind_srt;fixations(1)];
                        edf.events.fix.ind_end = [edf.events.fix.ind_end;fixations(2)];
                        
                        edf.events.fix.x_srt = [edf.events.fix.x_srt;xPos(fixations(1))];
                        edf.events.fix.y_srt = [edf.events.fix.y_srt;yPos(fixations(1))];
                        edf.events.fix.x_end = [edf.events.fix.x_end;xPos(fixations(2))];
                        edf.events.fix.y_end = [edf.events.fix.y_end;yPos(fixations(2))];
                        edf.events.fix.x_srt_pix = [edf.events.fix.x_srt_pix;xPos_pix(fixations(1))];
                        edf.events.fix.y_srt_pix = [edf.events.fix.y_srt_pix;yPos_pix(fixations(1))];
                        edf.events.fix.x_end_pix = [edf.events.fix.x_end_pix;xPos_pix(fixations(2))];
                        edf.events.fix.y_end_pix = [edf.events.fix.y_end_pix;yPos_pix(fixations(2))];

                        edf.events.fix.xdisp = [edf.events.fix.xdisp;max(xsamples)-min(xsamples)];
                        edf.events.fix.ydisp = [edf.events.fix.ydisp;max(ysamples)-min(ysamples)];

                        edf.events.fix.peak_vel = [edf.events.fix.peak_vel;max(vel(fixations(1):fixations(2)))];
                        edf.events.fix.avg_vel = [edf.events.fix.peak_vel;mean(vel(fixations(1):fixations(2)),'omitnan')];
                        edf.events.fix.peak_acc = [edf.events.fix.peak_acc;max(acc(fixations(1):fixations(2)))];
                        edf.events.fix.dur = [edf.events.fix.dur;dur];
                        edf.events.fix.artifact = [edf.events.fix.artifact;art];

                        % store it in a variable is_saccade to indicate
                        % whether this sample is a fixation
                        edf.samples.is_fixation(fixations(1):fixations(2)) = 1;
                    end
                end
            end
        end
    end
end