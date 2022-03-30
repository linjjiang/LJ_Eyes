function edf = output_trackloss(edf)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here
    edf.trackloss.nSamplesPerTrial(ii) = length(find(isnan(rp)));
    edf.trackloss.nBlinkPerTrial(ii) = length(blinkOn);
    edf.trackloss.pSamplesPerTrial(ii) = length(find(isnan(rp)))/length(rp);

end

