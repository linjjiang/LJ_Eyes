function [sys,unsys] = cal_sys_unsys(xend,yend,xtar,ytar)
% Calculate systematic and unsystematic errors
% By: Linjing Jiang
% Date: 10/5/22

% all input should be a M X N matrix
% M: different numbers of observations in a condition
% N: different conditions

% mean of target x and y location
xtar_mean = nanmean(xtar);
ytar_mean = nanmean(ytar);

% saccade endpoint location adjusted by the mean target location
xend_new = xend - xtar + xtar_mean;
yend_new = yend - ytar + ytar_mean;

% systematic error - one value
sys = sqrt((nanmean(xend_new) - xtar_mean).^2 + (nanmean(yend_new) - ytar_mean).^2);

% unsystematic error - one value
unsys = nanmean(sqrt((nanmean(xend) - xend).^2 + (nanmean(yend) - yend).^2));

end