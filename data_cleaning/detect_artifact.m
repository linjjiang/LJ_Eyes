function edf = detect_artifact(edf,set)
% Detect artifacts in the eye-tracking data, mainly:
% 1) Unrealistic gaze positions: eyes travel outside of the viewing screen
% 2) Missing values in the pupil data 
% 3) Blinks
% 4) Unrealistic, extremely large or small pupil value (3 MAD away from the median)
% Note: these four sets of artifacts may overlap

% Input: 
% edf structure (containing specific parameters), 
% edf1 structure (containing all data)
% set: analysis setting

% Outputs:
% edf structure with additional fields

%% Blink detection
edf = detect_blink(edf,set);

% store the blink index (all) in the edf.trackloss
% index of blink is in terms of edf.samples data
edf.trackloss.blink_ind = edf.blink.all_ind;

%% Other artifact detection

% Missing value in the pupil data
edf = get_missing_pupil(edf,set);

% Unrealistic gaze positions
edf = get_outside_gaze(edf,set);

% Un-physiological gaze velocity and acceleration
edf = get_extreme_gaze_vel(edf,set);

% Extremely large or small pupil values
% Must run this function after detecting blink and missing samples
edf = get_extreme_pupil(edf,set);

% Extremely large dilation/constriction speed and edge artifacts
% Must run this function after detecting blink and missing samples
edf = get_extreme_pupil_vel(edf,set);

%% Concatenate indexes of all the artifacts

% unique indexes of tracklosses
edf.trackloss.all_ind = unique(cat(1,edf.trackloss.blink_ind,edf.trackloss.missing_ind,...
    edf.trackloss.outside_ind,edf.trackloss.gvel_ind,edf.trackloss.psize_ind,...
    edf.trackloss.pvel_ind));

% store artifact indexes in samples
edf.samples.is_artifact = zeros(size(edf.samples.time));
edf.samples.is_artifact(edf.trackloss.all_ind) = 1;

% percentage of trackloss
edf.trackloss.perc = length(edf.trackloss.all_ind)/length(edf.samples.pupil_size);


end

