function edf = get_outside_gaze(edf,set)
% get the index of gaze posions outside of the boundary of the screen

edf.trackloss.outside_ind = find((abs(edf.samples.x_deg(:,set.eye))>edf.screen.xlim/2) | ...
    (abs(edf.samples.y_deg(:,set.eye))> edf.screen.ylim/2));

end

