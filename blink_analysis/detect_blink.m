function edf = detect_blink(edf,set)
% detect blink in the sample

% Input:
% methods: methods of performing blink detection
% 1. default blink detection from eyelink
% Definition: a period of saccade detector activity with the pupil data 
% missing for three or more samples in a sequence
% 2. default blink detection from eyelink with extension of time window
% 3. velocity algorithm by Mathot (2013)
% 4. noise-based algorithm by Hershman et al. (2018)

% extend (optional)
% if use methods 2, the length of time window extended prior and after
% blinks

% eye
% which eye to analyze
% 1. left, 2.right, 3.binocular

if set.eye ~= 3 % monocular analysis
    switch set.noise.blink_method
        case 1 % basic
            [onset_ind,offset_ind,onset_time,offset_time,nblink] = detect_blink_basic(edf,set);
        case 2 % basic + extension
            [onset_ind,offset_ind,onset_time,offset_time,nblink] = detect_blink_basic_extension(edf,set);
        case 3 % velocity algorithm
             [onset_ind,offset_ind,onset_time,offset_time,nblink] = detect_blink_vel(edf,set);
        case 4
            [onset_ind,offset_ind,onset_time,offset_time,nblink] = detect_blink_noise(edf,set);
    end
end

% store these data to edf structure
edf.blink.onset_ind = onset_ind;
edf.blink.offset_ind = offset_ind;
edf.blink.onset_time = onset_time;
edf.blink.offset_time = offset_time;
edf.blink.num = nblink;
edf.blink.all_ind = [];
for ii = 1:nblink
    ind = [onset_ind(ii):offset_ind(ii)]';
    edf.blink.all_ind = [edf.blink.all_ind;ind];
end

end

