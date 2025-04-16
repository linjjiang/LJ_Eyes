function edf = combine_saccades(edf,set)
% Combine saccades that are too close to each other
% Done after drift correction before primary saccade selection

comb_thres = set.sac.comb_threshold; % combine threshold, usually 25 ms by default

vel = edf.samples.vel_deg_clean_dc(:,set.eye);

edf.samples.is_saccade = zeros(size(edf.samples.time)); % does this sample belong to a saccade

ii = 1;

while ii < length(edf.events.sac_dc.trial) % for all saccades
    
    % check the current and the next saccade, and combine if they are too
    % close
    
    % current saccade offset
    curr_sac_off = edf.samples.time(edf.events.sac_dc.ind_end(ii));
    
    % next saccade onset
    next_sac_on = edf.samples.time(edf.events.sac_dc.ind_srt(ii+1));
    
    % calculate interval between saccades
    curr_next_dif = next_sac_on - curr_sac_off;
    
    % if the interval is shorter than comb_thres
    if curr_next_dif <= comb_thres
        % we combine these two saccades
        % new start position would be the original start position of the
        % first saccade
        % new end position would be the end position of the second saccade
        edf.events.sac_dc.msg_end(ii) = edf.events.sac_dc.msg_end(ii+1);
        edf.events.sac_dc.ind_end(ii) = edf.events.sac_dc.ind_end(ii+1);
        edf.events.sac_dc.x_end(ii) = edf.events.sac_dc.x_end(ii+1);
        edf.events.sac_dc.y_end(ii) = edf.events.sac_dc.y_end(ii+1);
        edf.events.sac_dc.x_end_pix(ii) = edf.events.sac_dc.x_end_pix(ii+1);
        edf.events.sac_dc.y_end_pix(ii) = edf.events.sac_dc.y_end_pix(ii+1);
        
        % the new amplitude is calculated by the distance between new saccade
        % endpoint and start point
        xDist = edf.events.sac_dc.x_end(ii) - edf.events.sac_dc.x_srt(ii);
        yDist = edf.events.sac_dc.y_end(ii) - edf.events.sac_dc.y_srt(ii);
        edf.events.sac_dc.amp(ii)  = sqrt((xDist*xDist) + (yDist*yDist));
        
        % the new peak velocity is the maximum peak velocity of two
        % saccades
        edf.events.sac_dc.peak_vel(ii) = max(edf.events.sac_dc.peak_vel(ii),edf.events.sac_dc.peak_vel(ii+1));
        
        % the new average velocity
        edf.events.sac_dc.avg_vel(ii) = mean(vel(edf.events.sac_dc.ind_srt(ii):edf.events.sac_dc.ind_end(ii)),'omitnan');
        
        % the new peak acceleration
        edf.events.sac_dc.peak_acc(ii) = max(edf.events.sac_dc.peak_acc(ii),edf.events.sac_dc.peak_acc(ii+1));
        
        % the new duration
        edf.events.sac_dc.dur(ii) = edf.samples.time(edf.events.sac_dc.ind_end(ii)) - ...
            edf.samples.time(edf.events.sac_dc.ind_srt(ii));
        
        % the new artifact
        edf.events.sac_dc.artifact(ii) = any([edf.events.sac_dc.artifact(ii),edf.events.sac_dc.artifact(ii+1)]);
        
        % the new saccade index
        edf.samples.is_saccade(edf.events.sac_dc.ind_srt(ii):edf.events.sac_dc.ind_end(ii)) = 1;
        
        % remove the second saccade
        edf.events.sac_dc.trial(ii+1) = [];
        edf.events.sac_dc.msg_srt(ii+1) = [];
        edf.events.sac_dc.msg_end(ii+1) = [];
        edf.events.sac_dc.ind_srt(ii+1) = [];
        edf.events.sac_dc.ind_end(ii+1) = [];
        edf.events.sac_dc.x_srt(ii+1) = [];
        edf.events.sac_dc.y_srt(ii+1) = [];
        edf.events.sac_dc.x_end(ii+1) = [];
        edf.events.sac_dc.y_end(ii+1) = [];
        edf.events.sac_dc.x_srt_pix(ii+1) = [];
        edf.events.sac_dc.y_srt_pix(ii+1) = [];
        edf.events.sac_dc.x_end_pix(ii+1) = [];
        edf.events.sac_dc.y_end_pix(ii+1) = [];
        edf.events.sac_dc.amp(ii+1) = [];
        edf.events.sac_dc.peak_vel(ii+1) = [];
        edf.events.sac_dc.avg_vel(ii+1) = [];
        edf.events.sac_dc.peak_acc(ii+1) = [];
        edf.events.sac_dc.dur(ii+1) = [];
        edf.events.sac_dc.artifact(ii+1) = [];
    end
    ii = ii + 1;
end

end