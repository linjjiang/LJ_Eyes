function edf = baseline_correction(edf,set)
% correct the pupil size based on the baseline

% calculate the baseline pupil size
% First of all, get the baseline data
ind_onset = find(edf.samples.msg == 2);
ind_offset = find(edf.samples.msg == 3);
ind = [];
for ii = 1:length(ind_onset)
ind = [ind ind_onset(ii):ind_offset(ii)];
end
% calculate the baseline value
if set.bcorr.base_method == 1 % mean
    base_pupil = mean(edf.samples.pupil_size_interp(ind,set.eye));
elseif set.bcorr.base_method == 2 % median
    base_pupil = median(edf.samples.pupil_size_interp(ind,set.eye));
end
edf.samples.base_pupil = base_pupil;

% Then, do baseline correction
edf.samples.pupil_size_corr = edf.samples.pupil_size_interp;
switch set.bcorr.method
    case 1 % substractive
        edf.samples.pupil_size_corr(:,set.eye) = edf.samples.pupil_size_interp(:,set.eye) - base_pupil;
    case 2 % divisive
        edf.samples.pupil_size_corr(:,set.eye) = (edf.samples.pupil_size_interp(:,set.eye) - base_pupil)/base_pupil;
end

end

