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
% offset index
offset_ind = blink_ind(2:2:length(blink_ind));

% actual blink time
onset_time = edf.samples.time(onset_ind);
offset_time = edf.samples.time(offset_ind);

% how many blinks in total
nblink = length(onset_ind);

end

