clc; clear; close all;

Options = {'anglenorth',0,... 'The angle in the north is 0 deg (this is the reference from our data, but can be any other)
           'angleeast',90,... 'The angle in the east is 90 deg
           'labels',{'N (0°)','NE (45°)','E (90°)','SE (135°)','S (180°)','SW (225°)','W (270°)','NW (315°)'},... 'If you change the reference angles, do not forget to change the labels.
           'freqlabelangle','auto',...
           'legendtype',0,...
           'min_radius',0.25,...
           'titlestring',''};
       
ax(1) = subplot(1,3,1);
[speed,direction] = WindRandomDistrib(8760,20);
[figure_handle,count,speeds,directions,Table] = WindRose(direction,speed,[Options,{'axes',ax(1)}]);

subplot(1,3,2);
[speed,direction] = WindRandomDistrib(8760,30);
[figure_handle,count,speeds,directions,Table] = WindRose(direction,speed,[Options,{'axes',gca}]);

[speed,direction] = WindRandomDistrib(8760,30);
[figure_handle,count,speeds,directions,Table] = WindRose(direction,speed,[Options,{'axes',subplot(1,3,3)}]);