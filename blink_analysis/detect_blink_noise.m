function [onset_ind,offset_ind,onset_time,offset_time,nblink] = detect_blink_noise(edf,set)
% noise-based blink detection (monocular)

% Input:
% edf
% eye: 1, left, 2, right

% Output:
% edf.blink

eye = set.eye;

% blink onset and offset time assuming the data starts from timepoint 0
blink_time_from_zero = based_noise_blinks_detection(edf.samples.pupil_size(:,eye),edf.record.sample_rate);

% blink index within the pupil data
blink_ind = blink_time_from_zero/(1000/edf.record.sample_rate);
% onset index
onset_ind = blink_ind(1:2:(length(blink_ind)-1));
if onset_ind(1) == 0
    onset_ind(1) = 1;
end
% offset index
offset_ind = blink_ind(2:2:length(blink_ind));

% extend the detected blink window by set.noise.blink_extend
ext_window = set.noise.blink_extend/(1000/edf.record.sample_rate);
for ii = 1:size(onset_ind,1)
    if onset_ind(ii) >= ext_window
onset_ind(ii) = onset_ind(ii) - ext_window;
    end

    if offset_ind(ii) + ext_window < length(edf.samples.time)
offset_ind(ii) = offset_ind(ii) + ext_window;
    end
end
% actual blink time
onset_time = edf.samples.time(onset_ind);
offset_time = edf.samples.time(offset_ind);

% how many blinks in total
nblink = length(onset_ind);

end

