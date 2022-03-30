function edf = get_extreme_pupil_vel(edf,set)
% detect dilation/constriction speed outliers

% calculate the dilation/constriction speed of the pupil
p = edf.samples.pupil_size;
tstep = 1000/edf.record.sample_rate; % time step in msec
p_diff1 = [diff(p);NaN NaN]; % the next element - the previous element % from 1 to n-1
p_diff2 = [NaN NaN;flipud(diff(flipud(p)))]; % the previous element - the next element, from 2 to n
pvel1 = double(p_diff1./tstep); % unit of pupil size per msec
pvel2 = double(p_diff2./tstep); % unit of pupil size per msec

% calculate the pupil change speed
for ii = 1:2
pvel(:,ii) = max([pvel1(:,ii),pvel2(:,ii)],[],2,'omitnan');
end
edf.samples.pupil_size_vel = pvel;

% detect outliers
indout = isoutlier(pvel(:,set.eye),'median','ThresholdFactor',set.extreme_pupil_vel.lamda);
edf.trackloss.pvel_ind = find(indout);

end

