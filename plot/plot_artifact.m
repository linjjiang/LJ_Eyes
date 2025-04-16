function plot_artifact(edf,out_dir,set)
% Plot artifacts across trials

p = edf.samples.pupil_size(:,set.eye);
time = (edf.samples.time - edf.samples.time(1))/1000;
x = edf.samples.x_deg(:,set.eye);
y = edf.samples.y_deg(:,set.eye);

blink_ind = edf.trackloss.blink_ind;
missing_ind = edf.trackloss.missing_ind;
ext_ind = edf.trackloss.psize_ind;
outside_ind = edf.trackloss.outside_ind;
pvel_ind = edf.trackloss.pvel_ind;
gvel_ind = edf.trackloss.gvel_ind;

f1 = figure('Visible','Off');clf
h{1} = histogram(p);
hold on
h{2} = plot(p(blink_ind),zeros(length(blink_ind),1),'+');
h{3} = plot(p(missing_ind),100*ones(length(missing_ind),1),'x');
h{4} = plot(p(ext_ind),200*ones(length(ext_ind),1),'o');
h{5} = plot(p(outside_ind),300*ones(length(outside_ind),1),'^');
h{6} = plot(p(pvel_ind),400*ones(length(pvel_ind),1),'*');
h{7} = plot(p(gvel_ind),500*ones(length(gvel_ind),1),'.');
ind = find(cellfun(@isempty,h));
str = {'~','blink','missing pupil','extreme pupil value','gaze out of boundary','extreme pupil velocity','extreme vel & acc'};
str(ind) = [];
legend(str)
xlabel('Pupil Size')
ylabel('Frequency')
title('Artifacts in pupil size distribution')
saveas(f1,fullfile(out_dir,['art_pupil_distribution','id_',edf.ID,'.jpg']))

for ii = set.plot.trial_srt:set.plot.trial_end

ind_trial = find(edf.samples.trial == ii);

f2 = figure('Visible','Off');clf
f2.Position = [0 0 1500 500];
subplot(1,3,1)
h{1} = plot(time(ind_trial),p(ind_trial));
hold on
h{2} = plot(time(intersect(blink_ind,ind_trial)),p(intersect(blink_ind,ind_trial)),'+');
h{3} = plot(time(intersect(missing_ind,ind_trial)),p(intersect(missing_ind,ind_trial)),'x');
h{4} = plot(time(intersect(ext_ind,ind_trial)),p(intersect(ext_ind,ind_trial)),'o');
h{5} = plot(time(intersect(outside_ind,ind_trial)),p(intersect(outside_ind,ind_trial)),'^');
h{6} = plot(time(intersect(pvel_ind,ind_trial)),p(intersect(pvel_ind,ind_trial)),'*');
h{7} = plot(time(intersect(gvel_ind,ind_trial)),p(intersect(gvel_ind,ind_trial)),'*');

ind = find(cellfun(@isempty,h));
str = {'~','blink','missing pupil','extreme pupil value','gaze out of boundary','extreme pupil velocity','extreme vel & acc'};
str(ind) = [];
legend(str)
xlabel('Time (s)')
ylabel('Pupil Size')
title(['Artifacts in pupil time course: trial ',num2str(ii)])

hold on
subplot(1,3,2)
h{1} = plot(time(ind_trial),x(ind_trial));
hold on
h{2} = plot(time(intersect(blink_ind,ind_trial)),x(intersect(blink_ind,ind_trial)),'+');
h{3} = plot(time(intersect(missing_ind,ind_trial)),x(intersect(missing_ind,ind_trial)),'x');
h{4} = plot(time(intersect(ext_ind,ind_trial)),x(intersect(ext_ind,ind_trial)),'o');
h{5} = plot(time(intersect(outside_ind,ind_trial)),x(intersect(outside_ind,ind_trial)),'^');
h{6} = plot(time(intersect(pvel_ind,ind_trial)),x(intersect(pvel_ind,ind_trial)),'*');
h{7} = plot(time(intersect(gvel_ind,ind_trial)),p(intersect(gvel_ind,ind_trial)),'*');

hold on
line([time(ind_trial(1)),time(ind_trial(end))],[-edf.screen.xlim/2,-edf.screen.xlim/2])
line([time(ind_trial(1)),time(ind_trial(end))],[edf.screen.xlim/2,edf.screen.xlim/2])
ind = find(cellfun(@isempty,h));
str = {'~','blink','missing pupil','extreme pupil value','gaze out of boundary','extreme pupil velocity','extreme vel & acc'};
str(ind) = [];
legend(str)
xlabel('Time (s)')
ylabel('Horizontal Eye Position (deg)')
title('Artifacts in gaze x time course')

hold on
subplot(1,3,3)
h{1} = plot(time(ind_trial),y(ind_trial));
hold on
h{2} = plot(time(intersect(blink_ind,ind_trial)),y(intersect(blink_ind,ind_trial)),'+');
h{3} = plot(time(intersect(missing_ind,ind_trial)),y(intersect(missing_ind,ind_trial)),'x');
h{4} = plot(time(intersect(ext_ind,ind_trial)),y(intersect(ext_ind,ind_trial)),'o');
h{5} = plot(time(intersect(outside_ind,ind_trial)),y(intersect(outside_ind,ind_trial)),'^');
h{6} = plot(time(intersect(pvel_ind,ind_trial)),y(intersect(pvel_ind,ind_trial)),'*');
h{7} = plot(time(intersect(gvel_ind,ind_trial)),p(intersect(gvel_ind,ind_trial)),'*');

hold on
line([time(ind_trial(1)),time(ind_trial(end))],[-edf.screen.ylim/2,-edf.screen.ylim/2])
line([time(ind_trial(1)),time(ind_trial(end))],[edf.screen.ylim/2,edf.screen.ylim/2])

ind = find(cellfun(@isempty,h));
str = {'~','blink','missing pupil','extreme pupil value','gaze out of boundary','extreme pupil velocity','extreme vel & acc'};
str(ind) = [];
legend(str)
xlabel('Time (s)')
ylabel('Vertical Eye Position (deg)')
title('Artifacts in gaze y time course')
saveas(f2,fullfile(out_dir,['artifact_trial',num2str(ii),'_',edf.ID,'.jpg']))
%pause
end

end

