function [merg_onset,merg_offset] = merger(onset,offset,dist)
% merge the onset and the offset of an array that are too close to
% each other

% Inputs:
% "onset": index of the onset of the to be examined subarray
% e.g., [1 10 20 50], meaning that some features (either nans, consecutive
% arrays etc.) starts at 1st element, 10th., 20th, and 50th element

% "offset": index of the offset
% e.g., [8 16 25 60], meaning that some features ends at 8th., 16th, 25th,
% and 60th element

% "dist": the minimum index distance between elements to be merged

% Example:
%onset = [1 10 20 50];
%offset = [8 16 25 60];
%[merg_onset,merg_offset] = merger(onset,offset,5) 
% combine elements if the offset of the current event's index and the onset of the next event's index <= 5

kk = 1;
while kk < length(onset)
    if onset(kk+1) - offset(kk) <= dist
        offset(kk) = offset(kk+1);
        onset(kk+1) = [];
        offset(kk+1)= [];
    else
        kk = kk + 1;
    end
end
merg_onset = onset;
merg_offset = offset;

end


