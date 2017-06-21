% Combining 1-Hot with logKG in this way DOES NOT WORK. This code was just
% used to test something out.

% Uses a knowledge gradient policy with a logistic regression belief model
% to come up with an hour of the week to test using simulated data. 
% Calls MATLAB functions developed by Yingfei Wang from her logistic KG work.

% Read in simulated data. Right now, this is just a modified copy of
% ParsedParam only with hour_of_week, auctions, clicks, cost, and value per
% conversion.KG
data = importdata('SimulatorOutput.csv');
numHOW = 168;

colHOW = 1;
colClick = 3;

% Logical array specifying whether a click was made. This binary outcome
% allows us to use Yingfei's algorithm and code.
click = logical(data(:,colClick));

X=diag(ones(numHOW,1));

theta_est = zeros(numHOW, 1);
for k = 1:numHOW
    clickK = click(data(:,colHOW) == k);
    avgClickK = sum(clickK)/length(clickK);
    theta_est(k) = log(1/avgClickK - 1);
end
q_est=ones(numHOW,1);

cd logisticKG_yingfei;

[indexX,KG]=logKG(X,theta_est,q_est);

cd ..;
