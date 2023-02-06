function edf = get_extreme_pupil_vel(edf,set)
% detect dilation/constriction speed outliers

if set.eye ~= 3
    ind1 = ones(size(edf.samples.pupil_size,1),1);
    ind1([edf.trackloss.blink_ind;edf.trackloss.missing_ind]) = 0;
    % calculate extreme values after excluding blinks or missing samples
    velp = edf.samples.velp(ind1==1,set.eye);
    % calculate outlier
    ind = find(isoutlier(velp,'median','ThresholdFactor',set.noise.pupil_vel));
    edf.trackloss.pvel_ind = ind;
end

end

