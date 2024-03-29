%% Purpose: Replicate stats (p, BF) with OSF data using matlab 
% (SPSS was used for thesis/paper).

% addpath('/imaging/ek03/toolbox/bayesFactor/')


%% Read data
% For ease, before using readtable(), delete the top row i.e. the merged cell describing which classification
rawD = readtable('ROIDecodingAccuracies.xlsx');
rawD = rawD(:,2:end); % remove subject ID column


%% One samples vs. chance
for r = 1:width(rawD)
  [p,bf10,bf01,meanD] = doBayes_onesample(rawD,rawD.Properties.VariableNames{r},r);
end


%% Paired samples (tool vs non-tool) for LOTC-Hand and IPS-Hand
fullList = rawD.Properties.VariableNames';
toCompare = [ contain(fullList,'LOTC_HAND_1');
  contain(fullList,'IPS_HAND_1')
  contain(fullList,'LOTC_OBJ_1');
  contain(fullList,'LOTC_TOOL_1')
  ]; %contain will grab with/out _1 so gets both relevant cols
names = {'LOTC_Hand_paired','IPS_Hand_paired', ...
  'LOTC_Object_paired','LOTC_Tool_paired' };
for r = 1:length(names)
  [p,bf10,bf01,meanDtool,meanDnontool] = doBayes_paired(rawD,names{r},toCompare(r,:));
end

%% END

function [p,bf10,bf01,meanD,CI,stats] = doBayes_onesample(rawD,nam,col)

d = table2array(rawD(:,col));
[bf10,p,CI,stats] = bf.ttest(d,0.5,'tail','right');
meanD = nanmean(d);
bf01 = 1/bf10;  %Convert to BF01 for absence of an effect
fprintf('\nName: %s\np = %s\nbf10 = %s\nbf01 = %s\nmean = %s\n', nam, num2str(p), num2str(bf10), num2str(bf01), num2str(meanD));

end


function [p,bf10,bf01,meanDtool,meanDnontool,CI,stats] = doBayes_paired(rawD,nam,col)


dtool = table2array(rawD(:,col(:,1)));
dnontool = table2array(rawD(:,col(:,2)));

[bf10,p,CI,stats] = bf.ttest(dtool,dnontool,'tail','right');
meanDtool = nanmean(dtool);
meanDnontool = nanmean(dnontool);
bf01 = 1/bf10;  %Convert to BF01 for absence of an effect
fprintf('\nName: %s\np = %s\nbf10 = %s\nbf01 = %s\nmean tool = %s\nmean nontool = %s\n', nam, num2str(p), num2str(bf10), num2str(bf01), num2str(meanDtool), num2str(meanDnontool));

end


%% Instant check
% rawD = readtable('/imaging/ek03/projects/tool_grasping/data.csv');
% [p,bf10,bf01,meanD] = doBayes_onesample(rawD,'LOTC-Tool_tools',9);
% [p,bf10,bf01,meanD] = doBayes_onesample(rawD,'LOTC-Tool_nontools',10);
% [p,bf10,bf01,meanDtool,meanDnontool] = doBayes_paired(rawD,'LOTC-Tool_paired',[9,10]);
%
% [p,bf10,bf01,meanD] = doBayes_onesample(rawD,'IPS-Tool_tools',19);
% [p,bf10,bf01,meanD] = doBayes_onesample(rawD,'IPS-Tool_nontools',20);
% [p,bf10,bf01,meanDtool,meanDnontool] = doBayes_paired(rawD,'IPS-Tool_paired',[19,20]);