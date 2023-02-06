function edf = cal_velacc(edf,set)

% calculate velocity/acceleration using 5-sample window. See
% Engbert and Kliegl, 2003. Denominator accounts for the
% six sample 'differences' used in numerator (i.e., n-2 to
% n+2 = 4 samples, n-1 to n+1 = 2 samples).
% https://github.com/sj971/neurosci-saccade-detection/blob/master/analyzeEyeData.m

% Must run this function before artifact detection
xPos = edf.samples.x(:,set.eye);
yPos = edf.samples.y(:,set.eye);
p = edf.samples.pupil_size(:,set.eye);
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
    pVel(ii) = (p(ii + 2) + p(ii + 1) - p(ii - 1) - p(ii - 2))/(6*sample_window);
end
Vel = sqrt(xVel.^2 + yVel.^2);

% Acceleration
for ii = 3:(size(xVel, 1) - 2) % 2 additional samples chopped off either end
    xAcc(ii) = (xVel(ii + 2) + xVel(ii + 1) - xVel(ii - 1) - xVel(ii - 2))/(6*sample_window);
    yAcc(ii) = (yVel(ii + 2) + yVel(ii + 1) - yVel(ii - 1) - yVel(ii - 2))/(6*sample_window);
    pAcc(ii) = (pVel(ii + 2) + pVel(ii + 1) - pVel(ii - 1) - pVel(ii - 2))/(6*sample_window);
end
Acc = sqrt(xAcc.^2 + yAcc.^2);

% Assign those variables to edf structure
edf.samples.velx = -32768*ones(size(edf.samples.x)); 
edf.samples.velx(:,set.eye) = xVel;

edf.samples.velx_deg = -32768*ones(size(edf.samples.x)); 
edf.samples.velx_deg(:,set.eye) = xVel/edf.screen.xpix_per_deg;

edf.samples.vely = -32768*ones(size(edf.samples.x)); 
edf.samples.vely(:,set.eye) = yVel;

edf.samples.vely_deg = -32768*ones(size(edf.samples.x)); 
edf.samples.vely_deg(:,set.eye) = yVel/edf.screen.ypix_per_deg;

edf.samples.velp = -32768*ones(size(edf.samples.x)); 
edf.samples.velp(:,set.eye) = pVel;

edf.samples.vel = -32768*ones(size(edf.samples.x)); 
edf.samples.vel(:,set.eye) = Vel;

edf.samples.vel_deg = -32768*ones(size(edf.samples.x)); 
edf.samples.vel_deg(:,set.eye) = Vel/edf.screen.xpix_per_deg;

edf.samples.accx = -32768*ones(size(edf.samples.x)); 
edf.samples.accx(:,set.eye) = xAcc;

edf.samples.accx_deg = -32768*ones(size(edf.samples.x)); 
edf.samples.accx_deg(:,set.eye) = xAcc/edf.screen.xpix_per_deg;

edf.samples.accy = -32768*ones(size(edf.samples.x)); 
edf.samples.accy(:,set.eye) = yAcc;

edf.samples.accy_deg = -32768*ones(size(edf.samples.x)); 
edf.samples.accy_deg(:,set.eye) = yAcc/edf.screen.ypix_per_deg;

edf.samples.accp = -32768*ones(size(edf.samples.x)); 
edf.samples.accp(:,set.eye) = pAcc;

edf.samples.acc = -32768*ones(size(edf.samples.x)); 
edf.samples.acc(:,set.eye) = Acc;

edf.samples.acc_deg = -32768*ones(size(edf.samples.x)); 
edf.samples.acc_deg(:,set.eye) = Acc/edf.screen.xpix_per_deg;

end