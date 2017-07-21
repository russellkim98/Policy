% A basic module to test logKG/init_logKG/learner_logKG. Simulates a week
% on a per hour basis. Starts off with a normal prior distribution of the
% coefficients of the logistic function and tries to learn the true curve
% with an online logKG policy. 

% historical data, max number of auctions per hour
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));
hrs = 168;

% initialize policy
[X,w_est,q_est] = init_logKG();
[M,d] = size(X);

% THE TRUTH
while 1
    wStar_0 = normrnd(-7,1);
    wStar_1 = normrnd(1,1);
    wStar=[wStar_0;wStar_1];
    truth=sigmoid(X*wStar);
    if truth(M) > 0.1
        break
    end
end

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,:));
end

for h=1:hrs
    % find KG and one-period rewards
    [X,w_est,q_est,bid] = logKG(X,w_est,q_est,10);
    bidIndex = find(X(:,2) == bid);
    % simulate number of auctions, clicks, and profit for the hour
    numAucts = poissrnd(auctions(h));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(bidIndex));
    % update estimates of w and q
    [X,w_est,q_est] = learner_logKG(X,w_est,q_est,bid,numAucts,numClicks);
end

% graph to see error
figure;
x = linspace(0,10)';
xX = [ones(length(x),1) x];
trueCurve = sigmoid(xX*wStar);
estCurve = sigmoid(xX*w_est);
h = plot(x,trueCurve);
hold on;
plot(x,estCurve);

[~,alt_best] = max(E_profit.*truth);
opt_bid = X(alt_best,2);
scatter(opt_bid,sigmoid([1 opt_bid]*wStar),[],get(h,'Color'),'*');
