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
% if the nearby two nan arrays are closer than the minimum distance index,
% then merge these two
[srt_nan_new,end_nan_new] = merger(srt_nan,end_nan,clean_dist);

% new index for artifacts
ind_new = [];
for ii = 1:length(srt_nan_new)
    ind_new = [ind_new srt_nan_new(ii):end_nan_new(ii)];
end

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

end

