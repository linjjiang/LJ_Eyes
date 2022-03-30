function plot_timecourse_raw(edf,top_dir,file_dir,out_dir,set)
% plot timecourse of pupil size, x, and y gaze values (deg) across trials

p = edf.samples.pupil_size(:,set.eye);
time = (edf.samples.time - edf.samples.time(1))/1000;
x = edf.samples.x_deg(:,set.eye);
y = edf.samples.y_deg(:,set.eye);

for ii = set.plot.trial_srt:set.plot.trial_end

ind_trial = find(edf.samples.trial == ii);

f2 = figure(2);clf
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
saveas(f2,[top_dir,file_dir,out_dir,'raw_trial',num2str(ii),'id_',edf.ID,'.jpg'])
%pause
end

end

