% Uses the first policy to come up with an optimal bid value using
% simulated data.

% Read in one month's worth of simulated data. Specifically, this data is
% from 6/15/15 (Monday). 
data = importdata('SimulatorOutput.csv');

% Calculate the click probability, the cost per click, and the value per
% click for each hour. 
colHOW = 1;
colAuct = 2;
colClick = 3;
colCost = 4;
colConv = 5;
pWC = data(:,colClick)./data(:,colAuct);
fCPC = data(:,colCost)./data(:,colClick);
fVPC = data(:,colConv)./data(:,colClick);

% Estimate the value per click, the difference between the bid and the
% cost per click, and the click probability function.  
avgFVPC = nansum(fVPC)/sum(~isnan(fVPC),1);
d = 7 - nansum(fCPC)/sum(~isnan(fCPC),1);

y = data(~isnan(data(:,colPWC)),colPWC);
% Y = log(1./y - ones(length(y),1)); would have used for linear regression
x = ones(length(y),1)*7;
% X = [ones(length(x),1) x]; would have used for linear regression
% theta = X\Y; would have used for linear regression



