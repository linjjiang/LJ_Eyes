function edf = get_calib(edf1,varargin)
% get calibration results

% Input:
% edf structure (containing specific parameters),
% edf1 structure (containing all data)

% Output: edf structure with a new field "calib_result"
% edf.calib.avg_error: average error
% edf.calib.max_error: maximum error
% edf.calib.pattern: calibration pattern (HV3, 9, 13...)

if ~isempty(varargin)
    edf = varargin{1};
end

% find the validation index
ind = find(contains(edf1.Events.Messages.info,'VALIDATION'));

% find the validation message
str = edf1.Events.Messages.info(ind);
% get rid of aborted validation
kk = 1;
for ii = 1:length(str)
    split_str = split(str{ii},' ');
    q = cellfun(@(x) isnumeric(x) && numel(x)==1, split_str);
    if length(split_str) >= 8
        if isempty(str2num(split_str{8}))
            if isempty(str2num(split_str{7}))
                if isempty(str2num(split_str{9}))
                    error('calibration results failure')
                else
                    avgError(kk) = str2num(split_str{9}); % average error
                    maxError(kk) = str2num(split_str{11}); % maximum error
                end
            else
                avgError(kk) = str2num(split_str{7}); % average error
                maxError(kk) = str2num(split_str{9}); % maximum error
            end
        else
            avgError(kk) = str2num(split_str{8}); % average error
            maxError(kk) = str2num(split_str{10}); % maximum error
        end
        pat = split_str{3}; % pattern: HV3,9,13...
        kk = kk + 1;
    end
end

% store the calibration results
edf.calib.avg_error = avgError;
edf.calib.max_error = maxError;
edf.calib.pattern = pat;
end

