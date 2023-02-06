function edf = get_extreme_gaze_vel(edf,set)
% get extremely large gaze velocity and acceleration

if set.eye ~= 3

    vel = edf.samples.vel_deg(:,set.eye);
    acc = edf.samples.acc_deg(:,set.eye);

    % find samples exceeding velocity and acceleration threshold
    ind = find(vel>=set.noise.gaze_vel | acc>=set.noise.gaze_acc);

    % store the index
    edf.trackloss.gvel_ind = ind;
end

end