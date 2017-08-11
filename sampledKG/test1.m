% A module to test init_KG and profit, specifically by graphing the
% alternative probability curves and the optimal bids for that curve based
% on expected profit from a click.

% Initialize the policy
[X,theta,p] = init_KG;
M = length(X);
K = length(theta);

% Find expected profit given a click for each alternative.  
profits = zeros(M,1);
for alt=1:M
    x = X(alt,:);
    profits(alt) = profit(x);
end

% Find optimal bid value and expected profit for an auction for each truth. 
bid_best = zeros(K,1);
F_best = zeros(K,1);
for k=1:K
    thetaStar=theta(:,k);
    F = phi(X*thetaStar);
    F(1) = 0;
    F = F.*profits;
    [maxF,index] = max(F);
    F_best(k) = maxF;
    bid_best(k) = X(index,2);
end

% Graph the truth curves, label the optimal bid value by a '*'
figure;
hold on;
for k=1:K
    t = theta(:,k);
    x = linspace(0,10)';
    X = [ones(length(x),1) x];
    prob = phi(X*t);
    h = plot(x,prob);
    c = get(h,'Color');
    scatter(bid_best(k),phi([1 bid_best(k)]*t),[],c,'*');
end
title('Possible Truth Curves and Their Optimal Bids');
xlabel('Value of Bid Placed (in Dollars)');
ylabel('Probability of Winning an Auction and Getting a Click');
hold off;