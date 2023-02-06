function edf = select_saccades_one_v3_long(edf,set)
% select specific saccade to analyze
% In our experiment, 
% 1) report one - interested in primary saccades
% 2) report all - interested in all saccades during the probe

% We also have some other criteria, e.g., 
% We want the saccade to have at least 1 degree amplitude, and at least 100
% ms
% We also want the saccade endpoint position to be 3 degrees within the
% item

for ii = 1:edf.events.num_trial
    % all the probe saccade
     ind = find(edf.events.sac.trial == ii & (edf.events.sac.msg_srt == set.sac.msg(1) | edf.events.sac.msg_srt == set.sac.msg(2)));
%          & edf.events.sac.amp >= 1 & edf.events.sac.dur >= 50 & ...
     % among those saccade, select the first one that enters 3.5 deg ROI from
     % each probed item
     x_end = edf.events.sac.x_end(ind);
     y_end = edf.events.sac.y_end(ind);

% If I flip the probe y location correctly, uncomment the following two
% lines, and comment line 30-34
%      x_tar = edf.param.tarx_deg(ii,:);
%      y_tar = edf.param.tary_deg(ii,:);

% 090522: I forgot to flip the y location for the probe (it's okay, it will
% just create an error when plotting), so I reassigned the stimulus
% location to the probe location below:
     x_tar = edf.param.stimx_deg(ii,edf.param.probe_order(ii));
     y_tar = edf.param.stimy_deg(ii,edf.param.probe_order(ii));

     edf.param.tarx(ii) = edf.param.stimx(ii,edf.param.probe_order(ii));
     edf.param.tary(ii) = edf.param.stimy(ii,edf.param.probe_order(ii));
     edf.param.tarx_deg(ii) = x_tar;
     edf.param.tary_deg(ii) = y_tar;

     % euclidean distance
     clear dist
     dist(:,1) = sqrt((x_tar(1) - x_end).^2 + (y_tar(1) - y_end).^2);

     % within 3.5 dva error
     [row,col] = find(dist <= set.sac.err);

     % number of saccade for each order position
     num_sac(ii,:) = histcounts(col,0.5:1:4.5)';  

     % primary saccade
     for jj = 1
         temp = find(col == jj);
         if ~isempty(temp)
     primary_sac_ind(ii,jj) = ind(row(temp(1)));
          primary_sac_err(ii,jj) = dist(row(temp(1)),jj);
         else
             primary_sac_ind(ii,jj) = nan;
             primary_sac_err(ii,jj) = nan;
         end
     end

     % most accurate saccade
     [err,temp] = min(dist);
     if ~isempty(temp)
     acc_sac_ind(ii,:) = ind(temp)';
     acc_sac_err(ii,:) = err;
     ind_temp = find(err>set.sac.err);
     acc_sac_ind(ii,ind_temp) = nan;
     acc_sac_err(ii,ind_temp) = nan;
     else
             acc_sac_ind(ii,:) = nan;
     acc_sac_err(ii,:) = nan;
 
     end
end

% Store those values
edf.cal.primary_sac_ind = primary_sac_ind;
edf.cal.primary_sac_err = primary_sac_err;

edf.cal.num_sac = num_sac; % number of saccades per order
edf.cal.acc_sac_ind = acc_sac_ind;
edf.cal.acc_sac_err = acc_sac_err;
edf.cal.num_nan = sum(any(isnan(primary_sac_err),2));

for ii = 1:length(primary_sac_ind)
    if ~isnan(primary_sac_ind(ii))
edf.cal.primary_sac_xsrt(ii,1) = edf.events.sac.x_srt(primary_sac_ind(ii));
edf.cal.primary_sac_ysrt(ii,1) = edf.events.sac.y_srt(primary_sac_ind(ii));
edf.cal.primary_sac_xend(ii,1) = edf.events.sac.x_end(primary_sac_ind(ii));
edf.cal.primary_sac_yend(ii,1) = edf.events.sac.y_end(primary_sac_ind(ii));
    else
edf.cal.primary_sac_xsrt(ii,1) = nan;
edf.cal.primary_sac_ysrt(ii,1) = nan;
edf.cal.primary_sac_xend(ii,1) = nan;
edf.cal.primary_sac_yend(ii,1) = nan;
    end
    if ~isnan(acc_sac_ind(ii))    
edf.cal.acc_sac_xsrt(ii,1) = edf.events.sac.x_srt(acc_sac_ind(ii));
edf.cal.acc_sac_ysrt(ii,1) = edf.events.sac.y_srt(acc_sac_ind(ii));
edf.cal.acc_sac_xend(ii,1) = edf.events.sac.x_end(acc_sac_ind(ii));
edf.cal.acc_sac_yend(ii,1) = edf.events.sac.y_end(acc_sac_ind(ii));
    else
edf.cal.acc_sac_xsrt(ii,1) = nan;
edf.cal.acc_sac_ysrt(ii,1) = nan;
edf.cal.acc_sac_xend(ii,1) = nan;
edf.cal.acc_sac_yend(ii,1) = nan; 
    end
end

% calculate latency
for ii = 1:length(primary_sac_err)
    if ~isnan(primary_sac_ind(ii))
primary_sac_tm(ii,1) = edf.samples.time(edf.events.sac.ind_srt(primary_sac_ind(ii)));
primary_sac_rt(ii,1) = primary_sac_tm(ii) - edf.events.msg.time(ii,11);
    else
        primary_sac_tm(ii,1)= nan;
        primary_sac_rt(ii,1) = nan;
    end
end
edf.cal.primary_sac_tm = primary_sac_tm;
edf.cal.primary_sac_rt = primary_sac_rt;

end