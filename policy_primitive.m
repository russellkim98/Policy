% Uses the first policy to come up with an optimal bid value using
% simulated data.

% Read in simulated data. Right now, this is just a modified copy of
% ParsedParam with hour_of_week, auctions, clicks, cost, and value per
% conversion.
data = importdata('SimulatorOutput.csv');
numHOW = 168;

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

% Estimate the value per click and the difference between the bid and the
% cost per click.  
avgFVPC = nansum(fVPC)/sum(~isnan(fVPC));
avgD = 7 - nansum(fCPC)/sum(~isnan(fCPC));

% Find theta values for each hour of the week indicator variable. 
theta = zeros(numHOW, 1);
for k = 1:168
    pWCk = pWC(data(:,colHOW) == k);
    avgPWCk = nansum(pWCk)/sum(~isnan(pWCk));
    if avgPWCk == 0
        disp("Error: Not enough data1");
    end
    theta(k) = log(1/avgPWCk - 1) + 7;
end

% Find the optimum bid value for a given hour of the week.
b = zeros(numHOW,1);
for k = 1:168
    fVPCk = fVPC(data(:,colHOW) == k);
    avgfVPCk = nansum(fVPCk)/sum(~isnan(fVPCk));
    
    fCPCk = fCPC(data(:,colHOW) == k);
    avgfCPCk = nansum(fCPCk)/sum(~isnan(fCPCk));
    dk = 7 - avgfCPCk;

    der = @(b) exp(theta(k)-b)*(avgfVPCk+dk-b)/(1+exp(theta(k)-b))^2 - ...
        1/(1+exp(theta(k)-b));
    b(k) = fzero(der,0);
end

plot(1:168, b);
axis([0 168 0 20]);
%y = pWC(~isnan(pWC));
%y(y==0) = 1e-6;
% Y = log(1./y - ones(length(y),1)); would have used for linear regression
% x = ones(length(y),1)*7;
% X = [ones(length(x),1) x]; would have used for linear regression
% theta = X\Y; would have used for linear regression



