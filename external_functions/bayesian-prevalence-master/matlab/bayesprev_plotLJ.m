function [xmap,pmap,h1,bound,posterior] = bayesprev_plotLJ(data,alpha)
% Bayesian prevalence inference is performed with three numbers: 
% k, the number of significant participants (e.g. sum of binary indicator
% variable)
% n, the number of participants in the sample
% alpha, the false positive rate

k = sum(data);
n = length(data);
if nargin<=6
    alpha = 0.05; % default value see 'help ttest'
end

% plot posterior distribution of population prevalence
figure
co = get(gca,'ColorOrder'); ci=1;
hold on

x = linspace(0,1,100);
posterior = bayesprev_posterior(x,k,n,alpha);
plot(x, posterior,'Color',co(ci,:));

% add MAP as a point
xmap = bayesprev_map(k,n,alpha);
pmap = bayesprev_posterior(xmap,k,n,alpha);
plot(xmap, pmap,'.','MarkerSize',20,'Color',co(ci,:));

% add lower bound as a vertical line
bound = bayesprev_bound(0.95,k,n,alpha);
line([bound bound], [0 bayesprev_posterior(bound,k,n,alpha)],'Color',co(ci,:),'LineStyle',':')

% add 95% HPDI
oil = 2;
iil = 4;
h1 = bayesprev_hpdi(0.95,k,n,alpha);
plot([h1(1) h1(2)],[pmap pmap],'Color',co(ci,:),'LineWidth',oil)
% add 50% HPDI
h2 = bayesprev_hpdi(0.5,k,n,alpha);
plot([h2(1) h2(2)],[pmap pmap],'Color',co(ci,:),'LineWidth',iil)

xlabel('Population prevalence proportion')
ylabel('Posterior density')

end

