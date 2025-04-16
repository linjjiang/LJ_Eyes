function plot_timecourse_clean(edf,out_dir,set)
% plot timecourse of pupil size, x, and y gaze values (deg) across trials

p = edf.samples.pupil_size_clean(:,set.eye);
time = (edf.samples.time - edf.samples.time(1))/1000;
x = edf.samples.x_deg_clean(:,set.eye);
y = edf.samples.y_deg_clean(:,set.eye);

f1 = figure('Visible','Off');clf
h{1} = histogram(p);
xlabel('Pupil Size')
ylabel('Frequency')
title('Pupil size distribution')
saveas(f1,fullfile(out_dir,['pupil_distribution_','id_',edf.ID,'.jpg']))

for ii = set.plot.trial_srt:set.plot.trial_end

ind_trial = find(edf.samples.trial == ii);

f2 = figure('Visible','Off');clf
f2.Position = [0 0 1500 500];
subplot(1,3,1)
h{1} = plot(time(ind_trial),p(ind_trial));
xlabel('Time (s)')
ylabel('Pupil Size')
title(['Pupil time course: trial ',num2str(ii)])

hold on
subplot(1,3,2)
h{1} = plot(time(ind_trial),x(ind_trial));
xlabel('Time (s)')
ylabel('Horizontal Eye Position (deg)')
title('Gaze x time course')

hold on
subplot(1,3,3)
plot(time(ind_trial),y(ind_trial));
xlabel('Time (s)')
ylabel('Vertical Eye Position (deg)')
title('Gaze y time course')
saveas(f2,fullfile(out_dir,['cleaned_trial',num2str(ii),'_',edf.ID,'.jpg']))
%pause
end

end

