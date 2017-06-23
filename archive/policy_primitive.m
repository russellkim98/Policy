% Uses the first policy to come up with an optimal bid value using
% simulated data.

% Read in simulated data. Right now, this is just a modified copy of
% ParsedParam only with hour_of_week, auctions, clicks, cost, and value per
% conversion.
data = importdata('SimulatorOutput.csv');
numHOW = 168;

% Calculate the click probability, the cost per click, and the value per
% click for each data point. 
colHOW = 1;
colAuct = 2;
colClick = 3;
colCost = 4;
colTCV = 5;
pWC = data(:,colClick)./data(:,colAuct);
fCPC = data(:,colCost)./data(:,colClick);
fVPC = data(:,colTCV)./data(:,colClick);

% Estimate the value per click and the difference between the bid and the
% cost per click. It's better to use the average for each HoW, as done
% below. 
%avgfVPC = nansum(fVPC)/sum(~isnan(fVPC));
%avgD = 7 - nansum(fCPC)/sum(~isnan(fCPC));

% Find theta values for each hour of the week indicator variable. 
theta = zeros(numHOW, 1);
for k = 1:numHOW
    pWCk = pWC(data(:,colHOW) == k);
    avgPWCk = nansum(pWCk)/sum(~isnan(pWCk));
    if avgPWCk == 0
        disp("Error: Not enough data1");
    end
    theta(k) = log(1/avgPWCk - 1) + 7;
end

% Find the optimum bid value for each hour of the week. First, find the
% value that maximizes the profit function, and then find the minimum of
% that value and the maximum bid value according to the bound q for the
% commission of the conversion.
b = zeros(numHOW,1);
bid = zeros(numHOW,1);
q = 1; % when q = 1, bid = b (the commission constr doesn't do anything)
for k = 1:168
    
    % Find average fVPC and D for each hour of the week k
    fVPCk = fVPC(data(:,colHOW) == k);
    avgfVPCk = nansum(fVPCk)/sum(~isnan(fVPCk));
    fCPCk = fCPC(data(:,colHOW) == k);
    avgfCPCk = nansum(fCPCk)/sum(~isnan(fCPCk));
    avgDk = 7 - avgfCPCk;

    der = @(b) exp(theta(k)-b)*(avgfVPCk+avgDk-b)/(1+exp(theta(k)-b))^2 - ...
        1/(1+exp(theta(k)-b));
    b(k) = fzero(der,0);
    bid(k) = min([b(k) q*avgfVPCk+avgDk]); 
 
end

% Plot the optimum bid values for each hour of the week.
plot(1:168, bid);
axis([0 168 0 20]);

% Would have used for linear regression
%y = pWC(~isnan(pWC));
%y(y==0) = 1e-6;
% Y = log(1./y - ones(length(y),1));
% x = ones(length(y),1)*7;
% X = [ones(length(x),1) x];
% theta = X\Y;

