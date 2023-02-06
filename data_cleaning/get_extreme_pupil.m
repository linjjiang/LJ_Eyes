function edf = get_extreme_pupil(edf,set)
% get the index of extreme pupil values
% % Must run this function after detecting blink and missing samples
if set.eye ~= 3
    ind1 = ones(size(edf.samples.pupil_size,1),1);
    ind1([edf.trackloss.blink_ind;edf.trackloss.missing_ind]) = 0;
    % calculate extreme values after excluding blinks or missing samples
    p = edf.samples.pupil_size(ind1==1,set.eye);
    % calculate outlier
    ind = find(isoutlier(p,'median','ThresholdFactor',set.noise.pupil_sz));
    edf.trackloss.psize_ind = ind;
end

end

