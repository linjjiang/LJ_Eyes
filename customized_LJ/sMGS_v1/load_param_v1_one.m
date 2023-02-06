function edf = load_param_v1_one(edf,set)
% Load parameter files
% Make sure you modify this function based on different experiments
% Go to the specific data folder
data_f = dir([edf.dir.data_dir,edf.dir.file_dir,'*TRIAL*.dat']);
params = [];
for ii = 1:length(data_f)
params = [params;readtable(data_f(ii).name)];
end

% 17:24: x and y location
% 4-7: order
% 31-38: timing

% 8: probe order
% 27-28: probe x and y location

x = params(:,17:20);
y = params(:,21:24);
ord = params(:,4:7);
tm = params(:,31:38);

tarx = params(:,27);
tary = params(:,28);
tar_ord = params(:,8);

% Store all the info
edf.param.datasource = (params);
edf.param.stimx = table2array(x);
edf.param.stimy = table2array(y);
edf.param.tarx = table2array(tarx);
edf.param.tary = table2array(tary);
[edf.param.stimx_deg,edf.param.stimy_deg] = pix2ang(edf.param.stimx,edf.param.stimy,edf);
[edf.param.tarx_deg,edf.param.tary_deg] = pix2ang(edf.param.tarx,edf.param.tary,edf);
edf.param.time = table2array(tm)*1000; % change to miliseconds
edf.param.quad_order = table2array(ord);
edf.param.probe_order = table2array(tar_ord);

end