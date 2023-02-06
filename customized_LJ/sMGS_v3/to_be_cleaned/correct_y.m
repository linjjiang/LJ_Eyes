function edf = correct_y(edf,set)
% flip 1 & 4
% flip 2 & 3 rd quadrant cue
% Adjust the probe quadrant, image, x and y locations
% Probe order is still the same

%p_quad = 5 - edf.param.probe_quad;
p_quad = edf.param.probe_quad;
s_quad = 5 - edf.param.quad_order;
edf.param.quad_order = s_quad;
for ii = 1:length(s_quad)
    s_order(ii,:) = [find(s_quad(ii,:)==1),find(s_quad(ii,:)==2),...
        find(s_quad(ii,:)==3),find(s_quad(ii,:)==4)]; % stimuli order
    edf.param.probe_order(ii) = s_order(ii,p_quad(ii)); % probe order
    ind = [9:12];
    edf.param.probe_img(ii) =table2array(edf.param.datasource(ii,ind(edf.param.probe_order(ii))));
    edf.param.tarx(ii) = edf.param.stimx(ii,edf.param.probe_order(ii));
    edf.param.tary(ii) = edf.param.stimy(ii,edf.param.probe_order(ii));
end

[edf.param.tarx_deg,edf.param.tary_deg] = pix2ang(edf.param.tarx,edf.param.tary,edf);

end