function edf = load_param_mgs(edf,set)
% Load parameter files
% Make sure you modify this function based on different experiments
% Go to the specific data folder
% 9/5 modified the file name in ''
%%
data_f1 = dir([edf.dir.data_dir,edf.dir.file_dir,'actual_TRIAL_DataSource_MGS_v3_Prac_BlockTRIAL.dat']);
data_f2 = dir([edf.dir.data_dir,edf.dir.file_dir,'actual_TRIAL_DataSource_MGS_v3_Session_BlockTRIAL.dat']);
params1 = readtable(data_f1.name);
params2 = readtable(data_f2.name);
params = [params1(:,1:30);params2];
%params = [readtable(data_f1.name);readtable(data_f2.name)];

% params = [];
% for ii = 1:2%length(data_f)
% params = [params;readtable(data_f(ii))];
% end
%% New code for the MGS/VGS task
indtar = table2array(params(:,8));%target index column 13
edf.param.indtar = indtar;

indtar = zeros(size(edf.samples.trial));
for ii = 1:144
ind = find(edf.samples.trial==ii);
indtar(ind) = edf.param.indtar(ii)*ones(length(ind),1);
end
edf.samples.indtar=indtar;
% 26:33: x and y location
%MGS 16-17 x and y location
% 4-7: order
% 45:52,54:57: timing

% 34: probe order
% 35: probe quadrant
% 36: probe image category
% 41-42: probe x and y location

%MGS: 11-12 target x and y
%MGS: 8 target index, 
%MGS 9 target ecc, 
%MGS 10 target angle pixels

%x = params(:,26:29);
x = params(:,16);
%y = params(:,30:33);
y = params(:,17);
%ord = params(:,4:7);
%tm = params(:,[45:52,54:57]);


tarx = params(:,11);
tary = params(:,12);
%tar_ord = params(:,34);
%tar_quad = params(:,35);
%tar_img = params(:,36);

% Store all the info
edf.param.datasource = (params);
edf.param.stimx = table2array(x);
edf.param.stimy = table2array(y); edf.param.stimy = edf.screen.yres - edf.param.stimy;
edf.param.tarx = table2array(tarx);
edf.param.tary = table2array(tary); edf.param.tary = edf.screen.yres - edf.param.tary;
[edf.param.stimx_deg,edf.param.stimy_deg] = pix2ang(edf.param.stimx,edf.param.stimy,edf);
[edf.param.tarx_deg,edf.param.tary_deg] = pix2ang(edf.param.tarx,edf.param.tary,edf);
%edf.param.time = table2array(tm)*1000; % change to miliseconds
%edf.param.quad_order = table2array(ord);
%edf.param.probe_order = table2array(tar_ord);
%edf.param.probe_quad = table2array(tar_quad);
%edf.param.probe_img = table2array(tar_img);

end