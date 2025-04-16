function [sys,unsys] = cal_sys_unsys(xend,yend,xtar,ytar,edf)
% Calculate systematic and unsystematic errors
% xend: endpoint position in pixel in x, N trials x M conditions
% yend: endpoint position in pixel in y,  N trials x M conditions
% xtar, ytar: target position in pixel,  N trials x M conditions
% edf: data structure from previous analysis

% By: Linjing Jiang
% Date: 10/5/22

% all input should be a N X M matrix
% N: different numbers of observations in a condition
% M: different conditions

% mean of target x and y location
xtar_mean = mean(xtar,'omitnan'); % 1 x M
ytar_mean = mean(ytar,'omitnan'); % 1 x M

% saccade endpoint location adjusted by the mean target location
xend_new = xend - xtar + xtar_mean;
yend_new = yend - ytar + ytar_mean;

% systematic error - one value
xerr = mean(xend_new,'omitnan') - xtar_mean;
yerr = mean(yend_new,'omitnan') - ytar_mean;
% actual size (cm) per pixel
xSzPerPix = edf.screen.w/edf.screen.xres;
ySzPerPix = edf.screen.h/edf.screen.yres;
   
% actual size (cm) between the dot and the axis
xSz = xSzPerPix*(xerr);
ySz = ySzPerPix*(yerr);
   
% degree of visual angle
angX = atand(xSz/edf.screen.d);
angY = atand(ySz/edf.screen.d);

% calculate systematic error
sys = sqrt(angX.^2 + angY.^2); % 1 x M matrix

% unsystematic error - one value
xerr1 = xend_new - mean(xend_new,'omitnan'); % N x M
yerr1 = yend_new - mean(yend_new,'omitnan'); % N x M
% actual size (cm) between the dot and the axis
xSz1 = xSzPerPix*(xerr1); % N x M
ySz1 = ySzPerPix*(xerr1); % N x M
% degree of visual angle
angX1 = atand(xSz1/edf.screen.d);
angY1 = atand(ySz1/edf.screen.d);

% calculate unsystematic error
% sum of standard deviation and then take a mean per condition
unsys = mean(sqrt(angX1.^2 + angY1.^2),'omitnan');

end