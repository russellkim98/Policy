% Uses a knowledge gradient policy with a logistic regression belief model
% to come up with an hour of the week to test using simulated data. 
% Calls MATLAB functions developed by Yingfei Wang from her logistic KG work.

% Read in simulated data. Right now, this is just a modified copy of
% ParsedParam only with hour_of_week, auctions, clicks, cost, and value per
% conversion.
data = importdata('SimulatorOutput.csv');
numHOW = 168;
colHOW = 1;
colClick = 3;

% Logical array specifying whether a click was made. This binary outcome
% allows us to use Yingfei's algorithm and code.
click = logical(data(:,colClick));
HOW = data(:, colHOW);
N = length(HOW);

% Each alternative is a different hour of the week.
X=[ones(numHOW,1),(1:numHOW)'];

[theta_est,~,stats] = glmfit(HOW,click,'binomial');
se = getfield(stats,'se');
var = se.*se.*N;
q_est = 1./var;

cd logisticKG_yingfei;

[indexX,KG]=logKG(X,theta_est,q_est);
plot(1:168,KG);

cd ..;

