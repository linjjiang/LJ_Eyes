function edf = detect_fixations_after_dc(edf,set)
% Detect fixations in the samples based on the criteria set in "settings"
% We need to run the fixcade detection first before running fixation
% detection function
% Dispersion-based fixation detection (I-DT, Reviewed in Salvucci & Goldberg, 
% 2000; Widdle 1984)
% % fixations are defined as samples with a velocity lower than or equal to 
% 10 dva/s, duration longer than or equal to 30 ms, and both horizontal and 
% vertical gaze dispersion smaller than or equal to 1.5 dva

% By: Linjing Jiang

vel = edf.samples.vel_deg_clean_dc(:,set.eye);
acc = edf.samples.acc_deg_clean_dc(:,set.eye);

xPos = edf.samples.x_deg_clean_dc(:,set.eye);
yPos = edf.samples.y_deg_clean_dc(:,set.eye);
xPos_pix = edf.samples.x_clean_dc(:,set.eye);
yPos_pix = edf.samples.y_clean_dc(:,set.eye);

ntr = edf.samples.ntrial;

% fixation thresholds
disp_th = set.fix.disp_threshold; % dispersion threshold for fixation
dur_th = set.fix.dur_threshold; % duration threshold for fixation
vel_th = set.fix.vel_threshold; % velocity threshold for fixation

% fixation detection
% preallocate memory
edf.events.fix_dc.trial = [];
edf.events.fix_dc.msg_srt = [];
edf.events.fix_dc.msg_end = [];
edf.events.fix_dc.ind_srt = [];
edf.events.fix_dc.ind_end = [];
edf.events.fix_dc.x_srt = [];
edf.events.fix_dc.y_srt = [];
edf.events.fix_dc.x_end = [];
edf.events.fix_dc.y_end = [];
edf.events.fix_dc.x_srt_pix = [];
edf.events.fix_dc.y_srt_pix = [];
edf.events.fix_dc.x_end_pix = [];
edf.events.fix_dc.y_end_pix = [];
edf.events.fix_dc.xdisp = [];
edf.events.fix_dc.ydisp = [];
edf.events.fix_dc.peak_vel = [];
edf.events.fix_dc.avg_vel = [];
edf.events.fix_dc.peak_acc = [];
edf.events.fix_dc.dur = [];
edf.events.fix_dc.artifact = [];
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
                        edf.events.fix_dc.trial = [edf.events.fix_dc.trial;ii];
                        edf.events.fix_dc.msg_srt = [edf.events.fix_dc.msg_srt;epoch_on];
                        edf.events.fix_dc.msg_end = [edf.events.fix_dc.msg_end;epoch_off];
                        edf.events.fix_dc.ind_srt = [edf.events.fix_dc.ind_srt;fixations(1)];
                        edf.events.fix_dc.ind_end = [edf.events.fix_dc.ind_end;fixations(2)];
                        
                        edf.events.fix_dc.x_srt = [edf.events.fix_dc.x_srt;xPos(fixations(1))];
                        edf.events.fix_dc.y_srt = [edf.events.fix_dc.y_srt;yPos(fixations(1))];
                        edf.events.fix_dc.x_end = [edf.events.fix_dc.x_end;xPos(fixations(2))];
                        edf.events.fix_dc.y_end = [edf.events.fix_dc.y_end;yPos(fixations(2))];
                        edf.events.fix_dc.x_srt_pix = [edf.events.fix_dc.x_srt_pix;xPos_pix(fixations(1))];
                        edf.events.fix_dc.y_srt_pix = [edf.events.fix_dc.y_srt_pix;yPos_pix(fixations(1))];
                        edf.events.fix_dc.x_end_pix = [edf.events.fix_dc.x_end_pix;xPos_pix(fixations(2))];
                        edf.events.fix_dc.y_end_pix = [edf.events.fix_dc.y_end_pix;yPos_pix(fixations(2))];

                        edf.events.fix_dc.xdisp = [edf.events.fix_dc.xdisp;max(xsamples)-min(xsamples)];
                        edf.events.fix_dc.ydisp = [edf.events.fix_dc.ydisp;max(ysamples)-min(ysamples)];

                        edf.events.fix_dc.peak_vel = [edf.events.fix_dc.peak_vel;max(vel(fixations(1):fixations(2)))];
                        edf.events.fix_dc.avg_vel = [edf.events.fix_dc.peak_vel;mean(vel(fixations(1):fixations(2)),'omitnan')];
                        edf.events.fix_dc.peak_acc = [edf.events.fix_dc.peak_acc;max(acc(fixations(1):fixations(2)))];
                        edf.events.fix_dc.dur = [edf.events.fix_dc.dur;dur];
                        edf.events.fix_dc.artifact = [edf.events.fix_dc.artifact;art];

                        % store it in a variable is_saccade to indicate
                        % whether this sample is a fixation
                        edf.samples.is_fixation(fixations(1):fixations(2)) = 1;
                    end
                end
            end
        end
    end
end