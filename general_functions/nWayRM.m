function [ranovatbl,Mrm,mau,eps,norm_p] = nWayRM(data,varargin)
% two-way repeated measures anova
% By: Linjing Jiang
% Example
% [ranovatbl,Mrm1,Mrm2] = nWayRM(ABSM,'eccentricity',{'3deg','8deg','13deg'},'delay',{'1500ms','2000ms','3000ms'})
% data is 12 x 9 matrix, rows are subjects and columns are different
% conditions
                % fact1:111,222,333
                % fact2:123,123,123

N = length(varargin);
if ~mod(N,2)
    nfac = N/2; % how many factors
    for ii = 1:nfac
        factors{ii} = varargin{ii*2-1}; % factor names
        conds{ii} = varargin{ii*2}; % condition names
        condNum(ii) = length(conds{ii}); % how many conditions for each factor
    end
    % name of the conditions
    varNames = cell(prod(condNum),1);
    for ii = 1:prod(condNum) %n1*n2
        v = strcat('V',num2str(ii));
        varNames{ii,1} = v;
    end
    %fact = cells{prod(condNum),nfac};
    %fact1 = cell(n1*n2,1); fact2 = cell(n1*n2,1);
    switch nfac
        case 1
            factCond = conds{1}; % all the conditions
            datamat = data;
            factName = factors; % factor names
                % create a table full of abstract variable names (v1-vn)
    tbl = array2table(datamat,'VariableNames',varNames);

    within = table(factCond','VariableNames',factName);
    rm = fitrm(tbl,['V1-V',num2str(condNum),'~1'],'WithinDesign',within);
    [ranovatbl] = ranova(rm,'WithinModel',factName{1});
    
    Mrm = multcompare(rm,factors,'ComparisonType','hsd');
   mau = mauchly(rm); eps = epsilon(rm);
        case 2
            n1 = condNum(1); n2 = condNum(2);
            for ii = 1:n1 % first factor
                % fact1:111,222,333
                % fact2:123,123,123
            datamat = data;%datamat(:,1+(ii-1)*n2:ii*n2) = squeeze(data(:,ii,:));
            factCond1(1+(ii-1)*n2:ii*n2,1) = repmat(conds{1}(ii),n2,1);
            factCond2(1+(ii-1)*n2:ii*n2,1) = conds{2};
            end
          % create a table full of abstract variable names (v1-vn)
    tbl = array2table(datamat,'VariableNames',varNames);
    
    within = table(factCond1,factCond2,'VariableNames',factors);
    rm = fitrm(tbl,['V1-V',num2str(n1*n2),'~1'],'WithinDesign',within);
    [ranovatbl] = ranova(rm,'WithinModel',[factors{1},'*',factors{2}]);
    Mrm.oneBytwo = multcompare(rm,factors{1},'By',factors{2},'ComparisonType','hsd');
    Mrm.twoByone = multcompare(rm,factors{2},'By',factors{1},'ComparisonType','hsd');
    Mrm.one = multcompare(rm,factors{1},'ComparisonType','hsd');
    Mrm.two = multcompare(rm,factors{2},'ComparisonType','hsd');
    mau = mauchly(rm); eps = epsilon(rm);
    
    temp = table2array(Mrm.one(:,3:4));
    cohend = temp(:,1)./temp(:,2); % mean/std
    tstat = temp(:,1)./temp(:,2)*sqrt(rm.DFE+1); % t statistics
    temp1 = array2table([tstat cohend],'VariableNames',{'t','Cohen d'});
    Mrm.one = [Mrm.one temp1];
    
    temp = table2array(Mrm.two(:,3:4));
    cohend = temp(:,1)./temp(:,2); % mean/std
    tstat = temp(:,1)./temp(:,2)*sqrt(rm.DFE+1); % t statistics
    temp1 = array2table([tstat cohend],'VariableNames',{'t','Cohen d'});
    Mrm.two = [Mrm.two temp1];
    
    % do simple effect analysis: fact 1 at different levels of fact 2
        
        for ii = 1:n2 % for each level of second factor
    datamat1 = datamat(:,[1:n1]+(ii-1)*n1); 
    clear varNames
    for jj = 1:n1 %n1*n2
        v = strcat('V',num2str(jj));
        varNames{jj,1} = v;
    end

    tbl1 = array2table(datamat1,'VariableNames',varNames);  
    within = table(conds{1}','VariableNames',{factors{1}});
    rm = fitrm(tbl1,['V1-V',num2str(n1),'~1'],'WithinDesign',within);
    [Mrm.anova1{ii}] = ranova(rm,'WithinModel',factors{1});
    end
    
    for ii = 1:n1 % for each level of first factor
    datamat2 = datamat(:,[ii:n1:ii+n1*(n2-1)]);
    
        clear varNames
    for jj = 1:n2 %n1*n2
        v = strcat('V',num2str(jj));
        varNames{jj,1} = v;
    end

    tbl2 = array2table(datamat2,'VariableNames',varNames);  
    within = table(conds{2}','VariableNames',{factors{2}});
    rm = fitrm(tbl2,['V1-V',num2str(n2),'~1'],'WithinDesign',within);
    [Mrm.anova2{ii}] = ranova(rm,'WithinModel',factors{2});
    normTestData = reshape(datamat,1,[]); 
    [~,norm_p,~] = swtest(normTestData);

    end
        case 3
            n1 = condNum(1); n2 = condNum(2); n3 = condNum(3); 
        for ii = 1:n1 % first factor
            factCond1(1+(ii-1)*n2*n3:ii*n2*n3,1) = repmat(conds{1}(ii),n2*n3,1);
            for jj = 1:n2 % second factor
                factCond2((ii-1)*n2*n3+(jj-1)*n3+1:(ii-1)*n2*n3+jj*n3,1) = repmat(conds{2}(jj),n3,1);
            factCond3((ii-1)*n2*n3+(jj-1)*n3+1:(ii-1)*n2*n3+jj*n3,1) = conds{3}';
                datamat(:,(ii-1)*n2*n3+(jj-1)*n3+1:(ii-1)*n2*n3+jj*n3) = squeeze(data(:,ii,jj,:));
            end
        end
        
% preset = 1:0.5:5; kk = 0; norm_p = 0;
% while (norm_p < .05) && (kk<=length(preset)-1)
% kk = kk + 1;
% newdata = datamat.^(1/preset(kk));
% newdata = reshape(newdata,1,[]); 
% [~,norm_p,~] = swtest(newdata);
% end

% figure;
% histogram(newdata)
% display(norm_p)
% display(preset(kk))

     % create a table full of abstract variable names (v1-vn)
    tbl = array2table(datamat,'VariableNames',varNames);

    within = table(factCond1,factCond2,factCond3,'VariableNames',factors);
    rm = fitrm(tbl,['V1-V',num2str(n1*n2*n3),'~1'],'WithinDesign',within);
ranovatbl = ranova(rm,'WithinModel',[factors{1},'*',factors{2},'*',factors{3}]);
mau = mauchly(rm); eps = epsilon(rm); Mrm = [];

Mrm.one = multcompare(rm,factors{1},'ComparisonType','hsd');
Mrm.two = multcompare(rm,factors{2},'ComparisonType','hsd');
Mrm.three = multcompare(rm,factors{3},'ComparisonType','hsd');

temp = table2array(Mrm.one(:,3:7));
cohend = temp(:,1)./temp(:,2); % mean/std
tstat = temp(:,1)./temp(:,2)*sqrt(rm.DFE+1); % t statistics
temp1 = array2table([tstat cohend],'VariableNames',{'t','Cohen d'});
Mrm.one = [Mrm.one temp1];

temp = table2array(Mrm.two(:,3:4));
cohend = temp(:,1)./temp(:,2); % mean/std
tstat = temp(:,1)./temp(:,2)*sqrt(rm.DFE+1); % t statistics
temp1 = array2table([tstat cohend],'VariableNames',{'t','Cohen d'});
Mrm.two = [Mrm.two temp1];

temp = table2array(Mrm.three(:,3:4));
cohend = temp(:,1)./temp(:,2); % mean/std
tstat = temp(:,1)./temp(:,2)*sqrt(rm.DFE+1); % t statistics
temp1 = array2table([tstat cohend],'VariableNames',{'t','Cohen d'});
Mrm.three = [Mrm.three temp1];

        otherwise error('Cannot do more than 3 variables')
    end
else error('inputs incorrect')
end
%             
%             
%     for ii = 1:nfac
%         for jj = 1:condNum(ii)
%         nrest = prod(condNum)/condNum(ii);
%         fact{(nrest*(jj-1)+1):(nrest*(jj-1)+nrest),ii} = repmat(conds{ii}{jj},nrest,1);
%         %fact1((3*(ii-1)+1):(3*(ii-1)+3)) = repmat(conds1(ii),3,1);
%         %fact2([ii ii+3 ii+6]) = repmat(conds2(ii),3,1);
%     end
%     factorNames = {factor1,factor2};
%     within = table(fact1,fact2,'VariableNames',factorNames);
%     
%     rm = fitrm(tbl,'V1-V9~1','WithinDesign',within);
%     [ranovatbl] = ranova(rm,'WithinModel',[factor1,'*',factor2]);
    
%     Mrm1 = multcompare(rm,factor1,'By',factor2,'ComparisonType','bonferroni');
%     Mrm2 = multcompare(rm,factor2,'By',factor1,'ComparisonType','bonferroni');
%     Mrm3 = multcompare(rm,factor1,'ComparisonType','bonferroni');
%     Mrm4 = multcompare(rm,factor2,'ComparisonType','bonferroni');
%     
end

