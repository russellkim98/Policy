% Tunes the number of auctions tau to look ahead in multi-step look-ahead
% offline version of KG policy. Runs a week-long simulation for each possible tau
% value.

% historical data, max number of auctions per hour
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(length(disc),1) disc];
M = length(X);

% thetas we are deciding between
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);

% THE TRUTH
thetaStar=theta(:,7);
truth = phi(X*thetaStar);

% input
taus = [1 2 4 6 8 10];
hrs = 50;

% result matrices
profits = zeros(length(taus),hrs);
probs = zeros(length(taus),10);

% Tune for number of steps to look ahead in mulitstep lookahead
for t=1:length(taus)
    
    [a,b,c] = initialize_KG();
    
    for i = 1:hrs
        [a,b,c,bid] = KG_ms(a,b,c,taus(t));
        bidIndex = find(X(:,2) == bid);
        numAucts = poissrnd(auctions(i));
        if numAucts > A
            numAucts = A;
        end
        numClicks = binornd(numAucts,truth(bidIndex));
        profits(t,i) = numClicks*(20 - bid);
        [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
        disp(i);
    end
    
    for j = 1:length(c)
        probs(t,j) = c(j);
    end
    
    t
end

figure;
plot(taus,sum(profits,2));
axis([0 max(taus) 0 max(sum(profits,2))]);

probs