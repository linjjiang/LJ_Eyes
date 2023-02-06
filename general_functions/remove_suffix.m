% 1. Trial-by-trial plotting of saccades and fixations
% 2. Messages
% 3. Mark noise & blinks
% Specify the folder where the files live.

myFolder = pwd;
%filePattern = fileDatastore(myFolder,"ReadFcn",@load,"FileExtensions",[".docx"]);

% Pattern to remove
suffix = '.docx';

% Get a list of all files in the folder with the desired file name pattern.
d = dir();
% remove '.' and '..' 
dfolders = d(~ismember({d(:).name},{'.','..'}));
% remove files
dfolders = dfolders([dfolders(:).isdir]);
for f = 1 : length(dfolders)
        theFiles = dir([dfolders(f).name '/*' suffix]);
for k = 1 : length(theFiles)
	baseFileName = theFiles(k).name;
	originalFullFileName = fullfile([myFolder '/' dfolders(f).name], baseFileName);
	% If there is no dot, skip it.
	if ~contains(baseFileName, suffix)
		continue; % Skip to bottom of loop.
	end
	% If it gets to here, there is a dot in the name.
	% Remove it
    newBaseFileName = strrep(baseFileName,suffix,'');
	newFullFileName = fullfile([myFolder '/' dfolders(f).name], newBaseFileName);
	fprintf(1, 'Now renaming %s to %s\n', originalFullFileName, newFullFileName);
	movefile(originalFullFileName, newFullFileName); % Do the rename.
end
end

theFiles = d(~[d(:).isdir]); % the large folder
for k = 1 : length(theFiles)
	baseFileName = theFiles(k).name;
	originalFullFileName = fullfile(myFolder, baseFileName);
	% If there is no dot, skip it.
	if ~contains(baseFileName, suffix)
		continue; % Skip to bottom of loop.
	end
	% If it gets to here, there is a dot in the name.
	% Remove it
    newBaseFileName = strrep(baseFileName,suffix,'');
	newFullFileName = fullfile(myFolder, newBaseFileName);
	fprintf(1, 'Now renaming %s to %s\n', originalFullFileName, newFullFileName);
	movefile(originalFullFileName, newFullFileName); % Do the rename.
end
