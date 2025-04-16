function edf = load_sample_after_dc(edf,set)

% calculate velocity/acceleration using 5-sample window. See
% Engbert and Kliegl, 2003. Denominator accounts for the
% six sample 'differences' used in numerator (i.e., n-2 to
% n+2 = 4 samples, n-1 to n+1 = 2 samples).
% https://github.com/sj971/neurosci-saccade-detection/blob/master/analyzeEyeData.m

% Must run this function before artifact detection
xPos = edf.samples.x_clean_dc(:,set.eye);
yPos = edf.samples.y_clean_dc(:,set.eye);

% pix to dva
[edf.samples.x_deg_clean_dc,edf.samples.y_deg_clean_dc] = pix2ang(edf.samples.x_clean_dc,edf.samples.y_clean_dc,edf);

% sample window
sample_window = 1/edf.record.sample_rate; %2ms i.e., 500Hz tracking

xVel = zeros(size(xPos)); 
yVel = zeros(size(yPos));
pVel = xVel;
Vel = xVel;

xAcc = xVel;
yAcc = xVel;
pAcc = xVel;
Acc = xVel;

% Velocity
for ii = 3:(size(xPos, 1) - 2) % 2 additional samples chopped off either end
    xVel(ii) = (xPos(ii + 2) + xPos(ii + 1) - xPos(ii - 1) - xPos(ii - 2))/(6*sample_window);
    yVel(ii) = (yPos(ii + 2) + yPos(ii + 1) - yPos(ii - 1) - yPos(ii - 2))/(6*sample_window);
end
Vel = sqrt(xVel.^2 + yVel.^2);

% Acceleration
for ii = 3:(size(xVel, 1) - 2) % 2 additional samples chopped off either end
    xAcc(ii) = (xVel(ii + 2) + xVel(ii + 1) - xVel(ii - 1) - xVel(ii - 2))/(6*sample_window);
    yAcc(ii) = (yVel(ii + 2) + yVel(ii + 1) - yVel(ii - 1) - yVel(ii - 2))/(6*sample_window);
end
Acc = sqrt(xAcc.^2 + yAcc.^2);

% Assign those variables to edf structure
edf.samples.velx_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.velx_clean_dc(:,set.eye) = xVel;

edf.samples.velx_deg_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.velx_deg_clean_dc(:,set.eye) = xVel/edf.screen.xpix_per_deg;

edf.samples.vely_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.vely_clean_dc(:,set.eye) = yVel;

edf.samples.vely_deg_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.vely_deg_clean_dc(:,set.eye) = yVel/edf.screen.ypix_per_deg;

edf.samples.vel_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.vel_clean_dc(:,set.eye) = Vel;

edf.samples.vel_deg_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.vel_deg_clean_dc(:,set.eye) = Vel/edf.screen.xpix_per_deg;

edf.samples.accx_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.accx_clean_dc(:,set.eye) = xAcc;

edf.samples.accx_deg_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.accx_deg_clean_dc(:,set.eye) = xAcc/edf.screen.xpix_per_deg;

edf.samples.accy_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.accy_clean_dc(:,set.eye) = yAcc;

edf.samples.accy_deg_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.accy_deg_clean_dc(:,set.eye) = yAcc/edf.screen.ypix_per_deg;

edf.samples.acc_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.acc_clean_dc(:,set.eye) = Acc;

edf.samples.acc_deg_clean_dc = -32768*ones(size(edf.samples.x)); 
edf.samples.acc_deg_clean_dc(:,set.eye) = Acc/edf.screen.xpix_per_deg;

end