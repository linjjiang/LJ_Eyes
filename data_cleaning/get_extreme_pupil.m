function edf = get_extreme_pupil(edf,set)
% get the index of extreme pupil values

if set.eye ~= 3
    p = edf.samples.pupil_size(:,set.eye);
    % calculate outlier
    ind = find(isoutlier(p,'median','ThresholdFactor',set.extreme_pupil.lamda));
    edf.trackloss.ext_ind = ind;
end

end

