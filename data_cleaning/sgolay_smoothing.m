function edf = sgolay_smoothing(edf,set)
% Filter gaze and pupil signals using the the Savitzky–Golay (SG) FIR smoothing filter
% Modified from the NYSTRÖM & HOLMQVIST (2010) toolbox

% SG filter described in Wikipedia:
% "A Savitzky–Golay filter is a digital filter that can be applied to a set 
% of digital data points for the purpose of smoothing the data, that is, 
% to increase the precision of the data without distorting the signal 
% tendency. This is achieved, in a process known as convolution, by fitting 
% successive sub-sets of adjacent data points with a low-degree polynomial 
% by the method of linear least squares."

% In NYSTRÖM & HOLMQVIST (2010), they recommended using the SG filter to
% smooth the gaze data because it 
% "makes no strong assumption on the overall shape of the velocity curve 
% and is reported to have a good performance in terms of preserving 
% high-frequency detail in the signal while maintaining both temporal and 
% spatial information about local maxima and minima (Savitzky & Golay,
% 1964)."
% They also argued that filtering the data could reduce glissades, a smaller, 
% saccade-like movement after saccadic movement that usually overshoot 
% its intended target followed by a quick corrective saccade back to the
% target (Robinson, & Hain, 1986; Weber & Daroff, 1972)

% Lowpass filter window length
smoothInt = 20/1000; % in seconds

% Span of filter
span = ceil(smoothInt*edf.record.sample_rate);

% Construct the filter
%--------------------------------------------------------------------------
N = 2;                 % Order of polynomial fit
F = 2*ceil(span)-1;    % Window length
% [b,g] = sgolay(N,F);   % Calculate S-G coefficients

% store the original gaze x, y location and pupil size
edf.samples.x_orig = edf.samples.x;
edf.samples.y_orig = edf.samples.y;
edf.samples.p_orig = edf.samples.pupil_size;
edf.samples.x_deg_orig = edf.samples.x_deg;
edf.samples.y_deg_orig = edf.samples.y_deg;

% Do trial-by-trial smoothing of the data
for ii = 1:edf.samples.ntrial
% the sample index of the current trial
idx = find(edf.samples.trial == ii);

% the x and y location, pupil size, as well as their velocity and
% acceleration for that trial
x = edf.samples.x_orig(idx,set.eye);
y = edf.samples.y_orig(idx,set.eye);
p = edf.samples.p_orig(idx,set.eye);
% velX = edf.samples.velx(idx,set.eye);
% velY = edf.samples.vely(idx,set.eye);
% velP = edf.samples.velp(idx,set.eye);
% accX = edf.samples.velx(idx,set.eye);
% accY = edf.samples.vely(idx,set.eye);
% accP = edf.samples.velp(idx,set.eye);

%%%%%%%% Do filtering %%%%%%%%
% Calculate the velocity and acceleration
% X = nanconv(x,g(:,1),'nanout');
% Y = nanconv(y,g(:,1),'nanout');
% P = nanconv(p,g(:,1),'nanout');
X = smoothdata(x,'sgolay',F,'includenan','Degree',N);
Y = smoothdata(y,'sgolay',F,'includenan','Degree',N);
P = smoothdata(p,'sgolay',F,'includenan','Degree',N);

% figure;
% subplot(1,2,1)
% plot(x,'k')
% hold on
% subplot(1,2,2)
% plot(X,'r')

% store the data back to edf.samples
edf.samples.x(idx,set.eye) = X;
edf.samples.y(idx,set.eye) = Y;
edf.samples.pupil_size(idx,set.eye) = P;
end

[edf.samples.x_deg,edf.samples.y_deg] = pix2ang(edf.samples.x,edf.samples.y,edf);


