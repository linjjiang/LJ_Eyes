function edf = get_params(edf1,varargin)
% get parameters from the data

% Inputs:
% edf1: the .mat structure converted from edf file

% Outputs:
% a new matlab structure "edf" containing the following fields:
% edf.record.
% sample_rate: sampling rate
% eye: which eye was recorded (left, right, or binocular)
% mode: recording mode (pupil or CR)
% pupil_mode: pupil type (area or diameter)

if ~isempty(varargin)
edf = varargin{1};
end

%% Get sampling rate
s_rate = edf1.RawEdf.RECORDINGS(:).('sample_rate'); % sample rate

% throw an error if the sampling rate changed during the expeirment
if length(unique(s_rate)) > 1
    error('The sampling rate changed during the experiment.')
end
    
edf.record.sample_rate = s_rate(1); % just want one value that reflects the entire session

%% Get eye recorded
eye = edf1.RawEdf.RECORDINGS(:).('eye'); % eye recorded

% throw an error if the sampling rate changed during the expeirment
if length(unique(eye)) > 1
    error('The eye recorded changed during the experiment.')
end

switch eye(1)
    case 1
        edf.record.eye = 'left';
    case 2
        edf.record.eye = 'right';
    case 3
        edf.record.eye = 'binocular';
end

%% Get recording mode
r_mode = edf1.RawEdf.RECORDINGS(:).('recording_mode'); % recording mode

% throw an error if the sampling rate changed during the expeirment
if length(unique(r_mode)) > 1
    error('The recording mode (pupil vs. CR) changed during the experiment.')
end

switch r_mode(1)
    case 0
        edf.record.mode = 'pupil';
    case 1
        edf.record.mode = 'CR';
end

%% Get pupil type
p_type = edf1.RawEdf.RECORDINGS(:).('pupil_type'); % recording mode

% throw an error if the sampling rate changed during the expeirment
if length(unique(p_type)) > 1
    error('The recording mode (pupil vs. CR) changed during the experiment.')
end

switch p_type(1)
    case 0
        edf.record.pupil_type = 'area';
    case 1
        edf.record.pupil_type = 'diameter';
end

end

