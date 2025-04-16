function edf = detect_saccades_after_dc(edf,set)
% Detect saccades in the samples based on the criteria set in "settings"
% after drift correction

vel = edf.samples.vel_deg_clean_dc(:,set.eye);
acc = edf.samples.acc_deg_clean_dc(:,set.eye);
xPos = edf.samples.x_deg_clean_dc(:,set.eye);
yPos = edf.samples.y_deg_clean_dc(:,set.eye);
xPos_pix = edf.samples.x_clean_dc(:,set.eye);
yPos_pix = edf.samples.y_clean_dc(:,set.eye);

vel_th = set.sac.vel_threshold; % velocity threshold
acc_th = set.sac.acc_threshold; % acceleration threshold
amp_th = set.sac.amp_threshold; % amplitude threshold
dur_th = set.sac.dur_threshold; % duration threshold

ntr = edf.samples.ntrial;

% saccade detection
% preallocate memory
edf.events.sac_dc.trial = [];
edf.events.sac_dc.msg_srt = [];
edf.events.sac_dc.msg_end = [];
edf.events.sac_dc.ind_srt = [];
edf.events.sac_dc.ind_end = [];
edf.events.sac_dc.x_srt = [];
edf.events.sac_dc.y_srt = [];
edf.events.sac_dc.x_end = [];
edf.events.sac_dc.y_end = [];
edf.events.sac_dc.x_srt_pix = [];
edf.events.sac_dc.y_srt_pix = [];
edf.events.sac_dc.x_end_pix = [];
edf.events.sac_dc.y_end_pix = [];
edf.events.sac_dc.amp = [];
edf.events.sac_dc.peak_vel = [];
edf.events.sac_dc.avg_vel = [];
edf.events.sac_dc.peak_acc = [];
edf.events.sac_dc.dur = [];
edf.events.sac_dc.artifact = [];
edf.samples.is_saccade = zeros(size(edf.samples.time)); % does this sample belong to a saccade

%%
for ii = 1:ntr % for each trial
    % find candidate samples beyond velocity AND acceleration threshold
    candidates = find(vel >= vel_th & edf.samples.trial == ii & edf.samples.is_artifact == 0);
    if candidates
        % check for multiple candidate saccades in single
        % trial, using threshold parameters defined at top
        % (see Engbert & Kliegl papers, and Eyelink manual)
        saccades = [];
        diffCandidates = diff(candidates);
        breaks = [0;find(diffCandidates > 1);size(candidates, 1)];
        for jj = 1:(size(breaks, 1) - 1) % for each saccade

            % find individual candidate saccades
            saccade = [candidates(breaks(jj) + 1) candidates(breaks(jj + 1))];

            % exceeds acceleration threshold?
            peakAcceleration = max(acc(saccade(1):saccade(2)));

            if peakAcceleration > acc_th

                % exceeds amplitude threshold?
                xDist = xPos(saccade(2)) - xPos(saccade(1));
                yDist = yPos(saccade(2)) - yPos(saccade(1));
                euclidDist = sqrt((xDist*xDist) + (yDist*yDist));
                if euclidDist > amp_th

                    % exceeds duration threshold?
                    dur = (saccade(2) - saccade(1))*1000/edf.record.sample_rate;

                    if dur > dur_th
                        % store saccade info
                        peakVelocity = max(vel(saccade(1):saccade(2)));
                        avgVelocity = mean(vel(saccade(1):saccade(2)));

                        % What task epoch this saccade belongs to
                        % saccade onset
                        epoch_on = edf.samples.msg(saccade(1));
                        % saccade offset
                        epoch_off = edf.samples.msg(saccade(2));

                        % Whether this saccade is near an artifact (within 25
                        % ms)
                        span = ceil(50/1000*edf.record.sample_rate);
                        if (saccade(1) - span) <= 0
                        art = any(isnan(edf.samples.x_deg_clean(1):(saccade(2) + span)));
                        else
                        art = any(isnan(edf.samples.x_deg_clean(saccade(1) - span):(saccade(2) + span)));
                        end

                        % store saccade info
                        edf.events.sac_dc.trial = [edf.events.sac_dc.trial;ii];
                        edf.events.sac_dc.msg_srt = [edf.events.sac_dc.msg_srt;epoch_on];
                        edf.events.sac_dc.msg_end = [edf.events.sac_dc.msg_end;epoch_off];
                        edf.events.sac_dc.ind_srt = [edf.events.sac_dc.ind_srt;saccade(1)];
                        edf.events.sac_dc.ind_end = [edf.events.sac_dc.ind_end;saccade(2)];
                        
                        edf.events.sac_dc.x_srt = [edf.events.sac_dc.x_srt;xPos(saccade(1))];
                        edf.events.sac_dc.y_srt = [edf.events.sac_dc.y_srt;yPos(saccade(1))];
                        edf.events.sac_dc.x_end = [edf.events.sac_dc.x_end;xPos(saccade(2))];
                        edf.events.sac_dc.y_end = [edf.events.sac_dc.y_end;yPos(saccade(2))];
                        edf.events.sac_dc.x_srt_pix = [edf.events.sac_dc.x_srt_pix;xPos_pix(saccade(1))];
                        edf.events.sac_dc.y_srt_pix = [edf.events.sac_dc.y_srt_pix;yPos_pix(saccade(1))];
                        edf.events.sac_dc.x_end_pix = [edf.events.sac_dc.x_end_pix;xPos_pix(saccade(2))];
                        edf.events.sac_dc.y_end_pix = [edf.events.sac_dc.y_end_pix;yPos_pix(saccade(2))];

                        edf.events.sac_dc.amp = [edf.events.sac_dc.amp;euclidDist];
                        edf.events.sac_dc.peak_vel = [edf.events.sac_dc.peak_vel;peakVelocity];
                        edf.events.sac_dc.avg_vel = [edf.events.sac_dc.peak_vel;avgVelocity];
                        edf.events.sac_dc.peak_acc = [edf.events.sac_dc.peak_acc;peakAcceleration];
                        edf.events.sac_dc.dur = [edf.events.sac_dc.dur;dur];
                        edf.events.sac_dc.artifact = [edf.events.sac_dc.artifact;art];

                        % store it in a variable is_saccade to indicate
                        % whether this sample is a saccade
                        edf.samples.is_saccade(saccade(1):saccade(2)) = 1;
                    end
                end
            end
        end
    end
end