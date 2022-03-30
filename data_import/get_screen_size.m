function edf = get_screen_size(edf,dft,varargin)
% get screen pamaeters

% windows will pop up to ask for basic screen parameters

%Input: 
% edf
% dft (default or not): Want to use default parameters? Please enter 0. 
% Want to enter your own screen parameters? Please enter 1.
% varargin: screen parameters
% d: viewing distance from the eye to the monitor (in cm)
% w: width of the screen (in cm)
% h: height of the screen (in cm)
% xres: horizontal resolution
% yres: vertical resolution

% Outputs:
% these parameters will be stored in the edf structure as the following
% fields:
% edf.screen.
% d: viewing distance from the eye to the monitor (in cm)
% w: width of the screen (in cm)
% h: height of the screen (in cm)
% xres: horizontal resolution
% yres: vertical resolution

% Default parameters (fMRI scan):
edf.screen.d = 60;
edf.screen.w = 37.7;
edf.screen.h = 30.2;
edf.screen.xres = 1024;
edf.screen.yres = 768;

if dft
    if length(varargin) == 5
edf.screen.d = varargin{1};
edf.screen.w = varargin{2};
edf.screen.h = varargin{3};
edf.screen.xres = varargin{4};
edf.screen.yres = varargin{5};
    else
    error('Please enter the full screen parameters.')
    end
end



end

