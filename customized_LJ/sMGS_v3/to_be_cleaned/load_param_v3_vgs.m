function edf = load_param_v3_vgs(edf)
% Load parameter files
% Make sure you modify this function based on different experiments
% Go to the specific data folder
data_f = dir([edf.dir.data_dir,edf.dir.file_dir,'*TRIAL*.dat']);

params = [];
for ii = 1:length(data_f)
params = [params;readtable(data_f(ii).name,'VariableNamingRule','preserve')];
end

% 26:33: x and y location
% 4-7: quadrant order
% 46:57: timing

% 34: probe order
% 35: probe quadrant
% 36: probe image category
% 42,43: probe x and y location

% x and y location of the target
x = params(:,7); 
y = params(:,8);

% timing
tm = params(:,[11:15]);

tarx = x;
tary = y;
tar_quad = params(:,3); % quadrant of the target
for kk = 1:size(params,1)
temp = params{kk,4}{1}; tar_img(kk,1) = str2num(temp(1)); % image of the target
end
%%
% Store all the info
edf.param.datasource = (params);
edf.param.stimx = table2array(x);
edf.param.stimy = table2array(y); edf.param.stimy = edf.screen.yres - edf.param.stimy;
edf.param.tarx = table2array(tarx);
edf.param.tary = table2array(tary); edf.param.tary = edf.screen.yres - edf.param.tary;
[edf.param.stimx_deg,edf.param.stimy_deg] = pix2ang(edf.param.stimx,edf.param.stimy,edf);
[edf.param.tarx_deg,edf.param.tary_deg] = pix2ang(edf.param.tarx,edf.param.tary,edf);
edf.param.time = table2array(tm)*1000; % change to miliseconds
edf.param.quad_order = [];
edf.param.probe_order = [];
edf.param.probe_quad = table2array(tar_quad);
edf.param.probe_img = tar_img;

end