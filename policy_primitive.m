% Uses the first policy to come up with an optimal bid value using
% simulated data.

% Read in one day's worth of simulated data.
data = importdata('SimulatorOutput.csv');

% Estimate the value per click, the difference between the bid and the cost
% per click, and the click probability function.  
colFVPC = 22;
colFCPC = 20;
colPWC = 17;
fVPC = nansum(data(:,colFVPC))/sum(~isnan(data(:,colFVPC)),1);
d = 7 - nansum(data(:,colFCPC))/sum(~isnan(data(:,colFCPC)),1);

y = data(~isnan(data(:,colPWC)),colPWC);
% Y = log(1./y - ones(length(y),1)); would have used for linear regression
x = ones(length(y),1)*7;
% X = [ones(length(x),1) x]; would have used for linear regression
% theta = X\Y; would have used for linear regression



