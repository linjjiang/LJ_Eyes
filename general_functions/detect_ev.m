ETparams.screenSz = [edf.screen.xres edf.screen.yres]; % pixels
ETparams.screenDim = [edf.screen.w edf.screen.h]/100; % meters
ETparams.viewingDist = edf.screen.d/100; % meters
ETparams.samplingFreq = double(edf.record.sample_rate); % Hz
ETparams.blinkVelocityThreshold = set.blink.vel_threshold;             
ETparams.blinkAccThreshold = set.blink.acc_threshold;               
ETparams.peakDetectionThreshold = set.sac.init_velpeak_threshold;              % Initial value of the peak detection threshold. 

ETparams.minFixDur = set.fix.min_dur; % in seconds
ETparams.minSaccadeDur = set.sac.min_dur; % in seconds

ETparams.data.X = edf.samples.x(:,set.eye)';
ETparams.data.Y = edf.samples.y(:,set.eye)';
ETparams.data.T = ones(size(ETparams.data.X));

global ETparams
%%
calVelAcc_sgolay(1,1)
detectAndRemoveNoise(1,1)

% iteratively find the optimal noise threshold
%-------------------------------------
ETparams.data(1,1).peakDetectionThreshold = ETparams.peakDetectionThreshold;
oldPeakT = inf;
while abs(ETparams.data(1,1).peakDetectionThreshold -  oldPeakT) > 1

    oldPeakT  = ETparams.data(1,1).peakDetectionThreshold;

    % Detect peaks in velocity (> X degrees/second)
    detectVelocityPeaks(1,1)

    % Find fixation noise level (0.7*global fixation noise +
    % 0.3*local fixation)
    detectFixationNoiseLevel(1,1)

end

% Detect saccades (with peak detection threshold (v < v_avg_noise + 3*v_std_noise))
% and glissades
%-------------------------------------
detectSaccades(1,1)

% Implicitly detect fixations
%-------------------------------------
detectFixations(1,1)

%% Copy the detected saccade & fixation data to edf structure
edf.samples.x_clean_sg(:,set.eye) = ETparams.data(1,1).X';
edf.samples.y_clean_sg(:,set.eye)  = ETparams.data(1,1).Y';
edf.samples.velx(:,set.eye)  = ETparams.data(1,1).velXorg';
edf.samples.vely(:,set.eye)  = ETparams.data(1,1).velYorg';
edf.samples.vel(:,set.eye)  = ETparams.data(1,1).velOrg';
edf.samples.vel_clean_sg(:,set.eye)  = ETparams.data(1,1).vel';
edf.samples.acc_clean_sg(:,set.eye)  = ETparams.data(1,1).acc';

edf.samples.sac(:,set.eye)  = ETparams.saccadeIdx.Idx';
edf.samples.fix(:,set.eye)  = ETparams.fixationIdx.Idx';
edf.samples.glisac(:,set.eye)  = ETparams.glissadeIdx.Idx';

edf.events.saccade.start = [ETparams.saccadeInfo(:).start];
edf.events.saccade.end = [ETparams.saccadeInfo(:).end];
edf.events.saccade.duration = [ETparams.saccadeInfo(:).duration];
edf.events.saccade.amplitude = [ETparams.saccadeInfo(:).amplitude];
edf.events.saccade.peakVelocity = [ETparams.saccadeInfo(:).peakVelocity];
edf.events.saccade.peakAcceleration = [ETparams.saccadeInfo(:).peakAcceleration];

edf.events.glissade.type = [ETparams.glissadeInfo(:).type];
edf.events.glissade.duration = [ETparams.glissadeInfo(:).duration];

edf.events.fixation.start = [ETparams.fixationInfo(:).start];
edf.events.fixation.end = [ETparams.fixationInfo(:).end];
edf.events.fixation.duration = [ETparams.fixationInfo(:).duration];
edf.events.fixation.x = [ETparams.fixationInfo(:).X];
edf.events.fixation.y = [ETparams.fixationInfo(:).Y];

