%% Plotting each trial
% for ii = 1:size(data,1) % each subject
jj = 1; % run 1
tt = 2; % trial 5
% edf = data{ii,jj};
% set = data_set{ii,jj};

figure(1);clf
ind = find(edf.samples.trial == tt);
tm = edf.samples.time;
X = edf.samples.x_deg_clean(:,set.eye);
Y = edf.samples.y_deg_clean(:,set.eye);
plot(tm(ind),X(ind),'LineWidth',2,'Color',[0, 0.4470, 0.7410]);
hold on
plot(tm(ind),Y(ind),'LineWidth',2,'Color',[0.8500, 0.3250, 0.0980]);
xlim([tm(ind(1)) tm(ind(end))])
xlabel('Time (msec)')
ylabel('Eye Position (deg)')
legend off;
%title(['Gaze time course: trial ',num2str(tt),' sub ',subs_id{ii},' run',num2str(jj)])
hold on

indm = edf.events.msg.ind_srt;
for kk = 1:size(indm,2)
    h = line([tm(indm(tt,kk)),tm(indm(tt,kk))],[min([X(ind);Y(ind)]),max([X(ind);Y(ind)])],'LineStyle','--','Color','k');
    text(tm(indm(tt,kk)),max([X(ind);Y(ind)])*0.9,0,num2str(edf.events.msg.txt(tt,kk)));
end

% plot saccades
inds = find(edf.events.sac.trial == tt);
sac_on = edf.events.sac.ind_srt(inds);
sac_off = edf.events.sac.ind_end(inds);

for kk = 1:length(inds)
    ind1 = sac_on(kk):sac_off(kk);
    plot(tm(ind1),X(ind1),'LineWidth',4,'Color',[0, 0.4470, 0.7410]);
    plot(tm(ind1),Y(ind1),'LineWidth',4,'Color',[0.8500, 0.3250, 0.0980]);
end

% plot target
hold on
for kk = 1%1:4 % there is only one target each trial
line([tm(indm(tt,1)),tm(indm(tt,size(indm,2)))],[edf.param.tarx_deg(tt,kk),edf.param.tarx_deg(tt,kk)],'LineStyle','--','Color',[0, 0.4470, 0.7410])
line([tm(indm(tt,1)),tm(indm(tt,size(indm,2)))],[edf.param.tary_deg(tt,kk),edf.param.tary_deg(tt,kk)],'LineStyle','--','Color',[0.8500, 0.3250, 0.0980])
% scatter(tm(indm(ii,jj)),edf.param.tarx_deg(ii,jj),40,[0, 0.4470, 0.7410]) %  stimx_deg
% scatter(tm(indm(ii,jj)),edf.param.tary_deg(ii,jj),40,[0.8500, 0.3250, 0.0980]) %  stimy_deg
% hold on
end
% saveas(figure(1),[subs_id{ii},'_run',num2str(jj),'_trial',num2str(tt),'_gaze.jpg']);

% end

% for jj = 1:4   
% line([tm(ind(1)),tm(ind(end))],[edf.param.tarx_deg(ii,jj) edf.param.tarx_deg(ii,jj)],'LineStyle','--','Color',[0, 0.4470, 0.7410]);
% line([tm(ind(1)),tm(ind(end))],[edf.param.tary_deg(ii,jj) edf.param.tary_deg(ii,jj)],'LineStyle','--','Color',[0.8500, 0.3250, 0.0980]);
% text(tm(ind(end))*0.9,edf.param.tarx_deg(ii,jj)*1,0,num2str(jj),"Color",[0, 0.4470, 0.7410]);
% text(tm(ind(end))*0.9,edf.param.tary_deg(ii,jj)*1,0,num2str(jj),"Color",[0.8500, 0.3250, 0.0980]);
% hold on
% end
