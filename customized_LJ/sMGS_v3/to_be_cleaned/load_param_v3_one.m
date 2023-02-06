function edf = load_param_v3_one(edf,set)
% Load parameter files
% Make sure you modify this function based on different experiments
% Go to the specific data folder
data_f = dir([edf.dir.data_dir,edf.dir.file_dir,'*TRIAL*.dat']);

params = [];
for ii = 1:length(data_f)
params = [params;readtable(data_f(ii).name,'VariableNamingRule','preserve')];
end

% 26:33: x and y location
% 4-7: order
% 45:52,54:57: timing

% 34: probe order
% 35: probe quadrant
% 36: probe image category
% 41-42: probe x and y location

x = params(:,26:29);
y = params(:,30:33);
ord = params(:,4:7);
tm = params(:,[45:52,54:57]);

tarx = params(:,41);
tary = params(:,42);
tar_ord = params(:,34);
tar_quad = params(:,35);
tar_img = params(:,36);

% Store all the info
edf.param.datasource = (params);
edf.param.stimx = table2array(x);
edf.param.stimy = table2array(y); edf.param.stimy = edf.screen.yres - edf.param.stimy;
edf.param.tarx = table2array(tarx);
edf.param.tary = table2array(tary); edf.param.tary = edf.screen.yres - edf.param.tary;
[edf.param.stimx_deg,edf.param.stimy_deg] = pix2ang(edf.param.stimx,edf.param.stimy,edf);
[edf.param.tarx_deg,edf.param.tary_deg] = pix2ang(edf.param.tarx,edf.param.tary,edf);
edf.param.time = table2array(tm)*1000; % change to miliseconds
edf.param.quad_order = table2array(ord);
edf.param.probe_order = table2array(tar_ord);
edf.param.probe_quad = table2array(tar_quad);
edf.param.probe_img = table2array(tar_img);

end