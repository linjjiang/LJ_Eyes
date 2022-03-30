function edf = do_interpolation(edf,set)
% Interpolation of the pupil data based on the methods set up in the setting file

ind = isnan(edf.samples.pupil_size_clean(:,set.eye)); % find all removed (nan) values in the array
diff_ind = diff(ind); % calculate difference between the index
interp_range = ceil(set.interp.range/(1000/edf.record.sample_rate)); % How many samples to interpolate prior and after
srt_nan = find(diff_ind == 1) + 1; % start of an nan array
end_nan = find(diff_ind == -1); % end of an nan array

% if the nearby two nan arrays are closer than the interpolation range,
% then merge these two
[srt_nan_new,end_nan_new] = merger(srt_nan,end_nan,interp_range);

% Do interpolation for each gap separately 
    edf.samples.pupil_size_interp = edf.samples.pupil_size_clean; % copy the cleaned pupil array (after removing all the artifacts) to the interpolation array
for ii = 1:length(srt_nan_new) % for each gap
    sample_ind = [(srt_nan_new(ii) - interp_range):(srt_nan_new(ii)-1) ...
        (end_nan_new(ii)+1) : (end_nan_new(ii) + interp_range)]; % sample index prior and after each nan array
    interp_ind = srt_nan_new(ii):end_nan_new(ii); % interpolation index: index for nan values
    sample_ind = double(sample_ind); interp_ind = double(interp_ind);
    values = edf.samples.pupil_size_clean(sample_ind,set.eye); % pupil size values correspond to sample index

    switch set.interp.method
        case 1
    interp_values = interp1(sample_ind,values,interp_ind,'linear'); % linear interpolation
        case 2
        interp_values = interp1(sample_ind,values,interp_ind,'spline'); % spline interpolation
    end
    edf.samples.pupil_size_interp(interp_ind,set.eye) = interp_values'; % fill in the interpolated values
end

end

