% historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(length(disc),1) disc];
M = length(X);

% the truth
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);
profits = zeros(M,1);
for alt=1:M
    x = X(alt,:);
    profits(alt) = profit(x);
end
thetaStar=theta(:,6);
truth = phi(X*thetaStar);
truth(1) = 0;
F = truth.*profits;
[~,index] = max(F);
bid_best = X(index,2);
truth_best = truth(index);

steps = 168;
tau = 15;

OC = zeros(steps,1);
bids = zeros(steps,1);
[a,b,c] = initialize_KG();

for i = 1:steps
    
    [a,b,c,bid,KG,reward] = KG_ms(a,b,c,tau);
    bidIndex = find(X(:,2) == bid);
    numAucts = poissrnd(auctions(i));
    numClicks = binornd(numAucts,truth(bidIndex));
    profit_actual = numClicks*(20 - bid);  
    profit_truth = binornd(numAucts,truth_best)*(20 - bid_best);
    
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
    
    OC(i) = profit_truth - profit_actual;
    bids(i) = bid;
    i
    
end

c
KG
OC
bids