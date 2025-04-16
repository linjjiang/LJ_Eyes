function edf = cal_saccades_endpoint(edf,set)
% Calculate the endpoint fixation (first fixation
% detected after the combined saccade) and store its index and mean
% position x and y with saccades

% should be done after drift correction

% In this script, I check upon the interval between two saccades
% to see if there is any fixation detected
% If there is one or more fixations, we take the first fixation after the
% saccade as the endpoint fixation

if ~isempty(edf.events.sac_dc.trial)
for ii = 1:length(edf.events.sac_dc.trial) % for all saccades
    
    % current saccade off index
    curr_sac_off_idx = edf.events.sac_dc.ind_end(ii);
    
    if ii < length(edf.events.sac_dc.trial)
    % next saccade onset index
    next_sac_on_idx = edf.events.sac_dc.ind_srt(ii+1);

    % is there any fixations in between current and next saccade?
    fix_idx = find(edf.events.fix_dc.ind_srt > curr_sac_off_idx & ...
                    edf.events.fix_dc.ind_srt < next_sac_on_idx);
    else % if it is the last saccade
        fix_idx = find(edf.events.fix_dc.ind_srt > curr_sac_off_idx & ...
                    edf.events.fix_dc.ind_srt < size(edf.samples.x,1));
    end
                
    if ~isempty(fix_idx) % if there is such fixation
        % we pick the first fixation as the saccade endpoint
        endfix_idx = fix_idx(1);
        
        % store the index in sac_dc
        edf.events.sac_dc.endfix(ii) = endfix_idx;
        
        % store the fixation start and end index
        edf.events.sac_dc.endfix_ind_srt(ii) = edf.events.fix_dc.ind_srt(endfix_idx);
        edf.events.sac_dc.endfix_ind_end(ii) = edf.events.fix_dc.ind_end(endfix_idx);
        
        % fixation sample index
        endfix_idx_sample = edf.events.sac_dc.endfix_ind_srt(ii) : edf.events.sac_dc.endfix_ind_end(ii);
        
        % store the fixation's mean position
        edf.events.sac_dc.endfix_avg_x_pix(ii) = mean(edf.samples.x_clean_dc(endfix_idx_sample,set.eye),'omitnan');
        edf.events.sac_dc.endfix_avg_y_pix(ii) = mean(edf.samples.y_clean_dc(endfix_idx_sample,set.eye),'omitnan');
        edf.events.sac_dc.endfix_avg_x(ii) = mean(edf.samples.x_deg_clean_dc(endfix_idx_sample,set.eye),'omitnan');
        edf.events.sac_dc.endfix_avg_y(ii) = mean(edf.samples.y_deg_clean_dc(endfix_idx_sample,set.eye),'omitnan');
        
        % store the fixation's duration
        edf.events.sac_dc.endfix_dur(ii) = edf.events.fix_dc.dur(endfix_idx);
        
    else % if there is no such fixation, we put it as nan
        edf.events.sac_dc.endfix(ii) = nan;
        edf.events.sac_dc.endfix_ind_srt(ii) = nan;
        edf.events.sac_dc.endfix_ind_end(ii) = nan;
        edf.events.sac_dc.endfix_avg_x_pix(ii) = nan;
        edf.events.sac_dc.endfix_avg_y_pix(ii) = nan;
        edf.events.sac_dc.endfix_avg_x(ii) = nan;
        edf.events.sac_dc.endfix_avg_y(ii) = nan;
        edf.events.sac_dc.endfix_dur(ii) = nan;        
    end
end
    
else
            edf.events.sac_dc.endfix = [];
        edf.events.sac_dc.endfix_ind_srt = [];
        edf.events.sac_dc.endfix_ind_end = [];
        edf.events.sac_dc.endfix_avg_x_pix = [];
        edf.events.sac_dc.endfix_avg_y_pix = [];
        edf.events.sac_dc.endfix_avg_x = [];
        edf.events.sac_dc.endfix_avg_y = [];
        edf.events.sac_dc.endfix_dur = [];     
        warning('No saccade detected for this run')
end
    
end