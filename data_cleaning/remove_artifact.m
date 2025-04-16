function edf = remove_artifact(edf,set)
% remove artifacts from the data

% index with artifacts
switch set.clean.artifact
    case 0
ind = edf.trackloss.all_ind;
    case 1
ind = edf.trackloss.blink_ind;        
    case 2
ind = edf.trackloss.missing_ind;         
    case 3
ind = edf.trackloss.outside_ind;   
    case 4
 ind = edf.trackloss.ext_ind;       
    case 5
        ind = edf.trackloss.pvel_ind;  
end

% merge artifacts if they are too close to each other
hypo_array = zeros(size(edf.samples.trial));
hypo_array(ind) = 1;
diff_ind = diff(hypo_array); % calculate difference between the array
clean_dist = ceil(set.clean.dist /(1000/edf.record.sample_rate)); % How many samples to interpolate prior and after
srt_nan = find(diff_ind == 1) + 1; % start of an nan array
end_nan = find(diff_ind == -1); % end of an nan array
if ~isempty(srt_nan) & ~isempty(end_nan)
if srt_nan(1) > end_nan(1)
srt_nan(2:end+1) = srt_nan;
srt_nan(1) = 1;
end
if srt_nan(end) > end_nan(end)
    end_nan(end+1) = length(hypo_array);
end
elseif isempty(srt_nan)
    srt_nan = 1;
elseif isempty(end_nan)
    end_nan = length(hypo_array);
end

% if the nearby two nan arrays are closer than the minimum distance index,
% then merge these two
[srt_nan_new,end_nan_new] = merger(srt_nan,end_nan,clean_dist);

% new index for artifacts
ind_new = [];
for ii = 1:length(srt_nan_new)
    ind_new = [ind_new srt_nan_new(ii):end_nan_new(ii)];
end
% store the final index
edf.trackloss.final_ind = ind_new;

% remove artifacts
edf.samples.pupil_size_clean = edf.samples.pupil_size;
edf.samples.pupil_size_clean(ind_new,set.eye) = NaN;

edf.samples.x_clean = edf.samples.x;
edf.samples.x_clean(ind_new,set.eye) = NaN;

edf.samples.y_clean = edf.samples.y;
edf.samples.y_clean(ind_new,set.eye) = NaN;

edf.samples.x_deg_clean = edf.samples.x_deg;
edf.samples.x_deg_clean(ind_new,set.eye) = NaN;

edf.samples.y_deg_clean = edf.samples.y_deg;
edf.samples.y_deg_clean(ind_new,set.eye) = NaN;

edf.samples.velx_deg_clean = edf.samples.velx_deg;
edf.samples.velx_deg_clean(ind_new,set.eye) = NaN;

edf.samples.vely_deg_clean = edf.samples.vely_deg;
edf.samples.vely_deg_clean(ind_new,set.eye) = NaN;

edf.samples.vel_deg_clean = edf.samples.vel_deg;
edf.samples.vel_deg_clean(ind_new,set.eye) = NaN;

edf.samples.accx_deg_clean = edf.samples.accx_deg;
edf.samples.accx_deg_clean(ind_new,set.eye) = NaN;

edf.samples.accy_deg_clean = edf.samples.accy_deg;
edf.samples.accy_deg_clean(ind_new,set.eye) = NaN;

edf.samples.acc_deg_clean = edf.samples.acc_deg;
edf.samples.acc_deg_clean(ind_new,set.eye) = NaN;

end

