function edf = get_missing_pupil(edf,set)
% get missing pupil values

if set.eye ~= 3
edf.trackloss.missing_ind = find(~edf.samples.pupil_size(:,set.eye));
end

end

