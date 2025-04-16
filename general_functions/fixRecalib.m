function T = fixRecalib(f,stimCoords)
%FIXRECALIB Summary of this function goes here
%   Detailed explanation goes here
T = fminsearch(@avgDistanceToClosestFixation, eye(2)); 

function avgDistance = avgDistanceToClosestFixation(transformation) 
    coords = (transformation*f); 
    distClosest = zeros(1, size(coords, 2)); 
    for fixNum = 1:size(coords, 2) 
        dist = zeros(1, size(stimCoords,2)); 
        for stimNum = 1:size(stimCoords,2); 
            dist(stimNum) = norm(coords(:,fixNum)-stimCoords(:,stimNum));
        end
        distClosest(fixNum) = min(dist); 
    end
    avgDistance = mean(distClosest); 
end
end