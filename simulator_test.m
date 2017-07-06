% historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% alternatives that we are deciding between
M = 25;
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% the truth
thetaStar=[-5;1];
truth = phi(X*thetaStar);

% time horizons to test
vals = [0.55 5.5 55 550];
t_max = 4;
profits = zeros(1,t_max);
probs = zeros(10,t_max);

for t_hor=1:t_max
    
    [a,b,c] = initialize_KG();
    profit = 0;
    for i = 1:168
        [a,b,c,bid] = KG_hr(a,b,c,vals(t_hor));
        bidIndex = find(X(:,2) == bid);
        numAucts = poissrnd(auctions(i));
        numClicks = binornd(numAucts,truth(bidIndex));
        profit = profit + numClicks*(42 - bid);
        [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
    end
    
    profits(t_hor) = profit;
    for i = 1:length(c)
        probs(i,t_hor) = c(i);
    end
    disp(t_hor);
    disp(profits);
    disp(probs);
    
end