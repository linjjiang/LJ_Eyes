function edf = load_param_v1_all(edf,set)
% Load parameter files
% Make sure you modify this function based on different experiments
% Go to the specific data folder
data_f = dir([edf.dir.data_dir,edf.dir.file_dir,'*TRIAL*.dat']);
params = readtable(data_f.name);

% 17:24: x and y location
% 4-7: order
% 31-38: timing

x = params(:,17:20);
y = params(:,21:24);
ord = params(:,4:7);
tm = params(:,31:38);

% Store all the info
edf.param.datasource = (params);
edf.param.tarx = table2array(x);
edf.param.tary = table2array(y);
[edf.param.tarx_deg,edf.param.tary_deg] = pix2ang(edf.param.tarx,edf.param.tary,edf);
edf.param.time = table2array(tm)*1000; % change to miliseconds
edf.param.quad_order = table2array(ord);

end