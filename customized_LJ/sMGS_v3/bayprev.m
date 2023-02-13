% Bayesian prevalence analysis

%% Load data
addpath(genpath('C:\Users\lj104\Documents\Linjing_Research\EyeAnalysis\LJ_Eyes\LJ_Eyes_developing'))

clear 
close all
clc

load stats.mat

%% Level 1: within-participant statistical analysis
% Any statistical test can be used. 
% Here, we want to test the quadratic trend of the order effects
err = stats.p_err_ord;
for ss = 1:size(err,1)
    data = squeeze(err(ss,:,5:8));
    if ~all(isnan(data),'all')
    %[row,col] = find(isnan(data));
    %data(unique(row),:) = nan;
    tbl{ss} = nWayRM_poly(data,'order',{'1','2','3','4'});
    p(ss) = tbl{ss}{3,7}; %{5,7} - quadratic effect; {3,7} - linear effect
    else
        p(ss) = nan;
    end
end

%% Level 2: Bayesian prevalence inference
% Bayesian prevalence inference is performed with three numbers: 
% k, the number of significant participants (e.g. sum of binary indicator
% variable)
% n, the number of participants in the sample
% alpha, the false positive rate
k = sum(p<0.05);
n = size(err,1);
alpha = 0.05; % default value see 'help ttest'

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
h = bayesprev_hpdi(0.95,k,n,alpha);
plot([h(1) h(2)],[pmap pmap],'Color',co(ci,:),'LineWidth',oil)
% add 50% HPDI
h = bayesprev_hpdi(0.5,k,n,alpha);
plot([h(1) h(2)],[pmap pmap],'Color',co(ci,:),'LineWidth',iil)

xlabel('Population prevalence proportion')
ylabel('Posterior density')
