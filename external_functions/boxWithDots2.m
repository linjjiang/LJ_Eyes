function boxWithDots2(data,label,p_val,comp)
%BOXWITHDOTS Summary of this function goes here
%   Detailed explanation goes here
% By: Linjing Jiang
% data: n x m, n is number of observations/datapoints/subjects, m is the
% number of groups
% label: cell with strings, showing the name of each group (m)
% p_val: N x 1, p values from N comparisons
% comp: N x 2 cell array, showing the exact comparisons


% index of p_val for each type of significance
% ind{1} = find(p_val <=.001);
% ind{2} = find(p_val <=.01 & p_val >.001);
% ind{3} = find(p_val <=.05 & p_val >.01);

% row index of comparisons for each type of significance
% for ii = 1:3
%     pairs1{ii} = comp(ind{ii},:); 
%     pairs1{ii} = unique(sort(pairs1{ii},2),'rows');
% end

% plot box plot 
h = boxplot(data,'Labels',label); % old version: h = boxplot([allData{:}],group);
set(h, 'linewidth' ,2)
set(gca,'FontSize',20)
hold on
xCenter = ones(size(data)).*[1:size(data,2)];
xCenter = xCenter + (-1 + 2* rand(size(data)))*0.1;
xCenter(isnan(data)) = NaN;
x1 = reshape(xCenter,1,[]); y1 = reshape(data,1,[]);
scatter(x1,y1,'lineWidth',0.1,'markerFaceColor',[0.8 0.8 0.8],'markerEdgeColor',[0.2 0.2 0.2])

hold on
if ~isempty(p_val)
sigstar(comp,p_val)
end
%hold on
%line([1 2],data((data(:,1)> data(:,2)),1:2),'linestyle','--','linewidth',1.5,'color',[0.2 0.2 0.2])
%line([4 5],data((data(:,4)> data(:,5)),1:2),'linestyle','--','linewidth',1.5,'color',[0.2 0.2 0.2])

end

