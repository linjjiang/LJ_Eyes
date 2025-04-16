function edf = load_sample(edf1,varargin)
% Load samples: 
% x, y gaze positions
% pupil size

% Input: edf1
% varargin: edf, if an edf structure has already been created

% Output: edf with the following field
% edf.samples.
% ntrial
% pupil_size
% x, y
% pix_per_degree_x, pix_per_degree_y
% msg (message)

if ~isempty(varargin)
edf = varargin{1};
set = varargin{2};
file_dir = varargin{3};
out_dir = varargin{4};
end

% number of trials
ntrial = size(edf1.Events.Start.time,2); 
if ntrial > 16 % the last trial is a baseline trial, we do not want to keep it
edf.samples.ntrial = 16;
else
    edf.samples.ntrial = ntrial;
end

% time
edf.samples.time = edf1.Samples.time;

% pupil size
edf.samples.pupil_size = edf1.Samples.pa;

% gaze positions
edf.samples.x = edf1.Samples.gx;
edf.samples.y = edf.screen.yres - edf1.Samples.gy; % Flip Y

% screen pixels per degree
edf.samples.pix_per_deg_x = edf1.Samples.rx;
edf.samples.pix_per_deg_y = edf1.Samples.ry;

% gaze positions (degree)
% edf.samples.x_deg = (edf.samples.x - edf.screen.xres/2) ./ edf.samples.pix_per_deg_x;
% edf.samples.y_deg = (edf.samples.y - edf.screen.yres/2) ./ edf.samples.pix_per_deg_y;
[edf.samples.x_deg,edf.samples.y_deg] = pix2ang(edf.samples.x,edf.samples.y,edf);

% default online parser events from eyelink
edf.default_events = edf1.Events; 

% trial index
for ii = 1:ntrial
[~,indsrt] = min(abs(edf.default_events.Start.time(ii)-edf.samples.time));
[~,indend] = min(abs(edf.default_events.End.time(ii)-edf.samples.time));
edf.trial.ind_srt(ii) = indsrt;
edf.trial.ind_end(ii) = indend;
edf.samples.trial(indsrt:indend,1) = repmat(ii,length(indsrt:indend),1);
end

% % messages - we will load messages in detect_epoch script
% edf.samples.msg = zeros(size(edf.samples.trial));
% for ii = 1:length(set.msg)
% clear ind indd
% ind = find(contains(edf.default_events.Messages.info,set.msg{ii}));
% for jj = 1:length(ind)
% [~,indd(jj)] = min(abs(edf.samples.time-edf.default_events.Messages.time(ind(jj))));
% end
% edf.samples.msg(indd) = ii;
% end
% 
% sum(edf.samples.msg == ii)
% find(contains(edf.default_events.Messages.info,'TrSrt'))

edf.screen.xlim = edf.screen.xres/edf.samples.pix_per_deg_x(1);
edf.screen.ylim = edf.screen.yres/edf.samples.pix_per_deg_y(1);

% data directory
edf.dir.file_dir = file_dir; 
edf.dir.out_dir = out_dir;

end


