function edf = drift_correction(edf,set)
% Perform drift correction of eye data offline
% Perform drift correction of the gaze position trial by trial based on the
% selected fixation period
% Using Vadillo et al. 2015 method

% The drift correction is performed in the following two steps:
% Step 1: Use “fminsearch” to estimate a linear transformation matrix while 
% minimizing the mean distance between the selected fixations during the 
% fixation period (baseline) and the center cross
% Step 2: Apply the transformation matrix to all samples trial by trial
% via multiplication

% How do we determine baseline:
% Select all fixations during the fixation period that are less than or
% equal to x dva
% Luckily, we have already parsed out fixation at this point (see
% detect_fixations.m)

% screen_distance = set.screen.d;
% screen_width = set.screen.w;
% screen_height = set.screen.h;
screen_res = [set.screen.xres,set.screen.yres];

edf.trackloss.nodc_trial = [];
edf.samples.x_clean_dc = edf.samples.x_clean;
edf.samples.y_clean_dc = edf.samples.y_clean;
edf.samples.baseline_dc = zeros(size(edf.samples.time));

% drift correction threshold
%dc_thres = set.noise.dc_threshold;
bs_ratio = set.noise.baseline_ratio; % baseline ratio to the fixation period length 
for ii = 1:edf.samples.ntrial
    idx_tr = find(edf.samples.trial == ii);
    % we only want to perform drift correction using 750 ms before the
    % stimulus onset
    fx_idx = find(edf.samples.msg == 2 & edf.samples.trial == ii); % fixation period idx (message 2-3, trial ii)
    % It is possible that we could not find fx_idx
    if ~isempty(fx_idx)
    fx_len = length(fx_idx); % total length of the fixation period 
    bs_idx = fx_idx(floor(fx_len*(1-bs_ratio)):fx_len); % baseline index
    bs_trial = zeros(size(edf.samples.time)); bs_trial(bs_idx) = 1; % put samples at baseline index to 1
    
    idx_fix = find(edf.samples.is_fixation == 1 & ... % is a fixation
                   edf.samples.trial == ii & ... % trial number equals ii
                   bs_trial == 1); % during predetermined baseline period        
%                  abs(edf.samples.x_deg_clean(:,set.eye)) <= dc_thres & ... % x position less than 3 dva
%                  abs(edf.samples.y_deg_clean(:,set.eye)) <= dc_thres); % y position less than 3 dva

    % if there is such fixation that meets all the above criteria
    if ~isempty(idx_fix)
        
    % calculate the fixation coordinates (average)
    fix_coords(1,1) = mean(edf.samples.x_clean(idx_fix,set.eye),'omitnan');
    fix_coords(2,1) = mean(edf.samples.y_clean(idx_fix,set.eye),'omitnan');
    
    % stimulus (center cross coordinates)
    stim_coords(1,1) = screen_res(1)/2;
    stim_coords(2,1) = screen_res(2)/2;

    % get the data that needs to be transformed
    % has to be a 2 x N matrix
    % first row - x, second row -y, columns - trials/time points
    x_clean = edf.samples.x_clean(idx_tr,set.eye)';
    y_clean = edf.samples.y_clean(idx_tr,set.eye)';  
    data = [x_clean;y_clean];

    % calculate transformation matrix
    T = fixRecalib(fix_coords,stim_coords); edf.samples.dc_matrix{ii} = T;

    % transform the data
    corrected_data = (T*data)';

    % store the transformed data
    edf.samples.x_clean_dc(idx_tr,set.eye) = corrected_data(:,1);
    edf.samples.y_clean_dc(idx_tr,set.eye) = corrected_data(:,2);    

    % store the baseline index
    edf.samples.baseline_dc(idx_fix) = 1;

    else % if there is no fixations that meet the current threshold
        % we discard that trial (fixation too far away from the center
        % cross)
        edf.trackloss.nodc_trial = [edf.trackloss.nodc_trial,ii];
    end
    else
        edf.trackloss.nodc_trial = [edf.trackloss.nodc_trial,ii];
    end
       
end

end

