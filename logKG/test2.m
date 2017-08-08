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
[X,w_est,q_est] = init_logKG(2);
X(:,2) = 1;
[M,~] = size(X);

% THE TRUTH
while 1
    wStar_0 = normrnd(-7,1);
    wStar_1 = normrnd(1,1);
    wStar=[wStar_1;wStar_0];
    truth=sigmoid(X*wStar);
    if truth(M) > 0.1
        break
    end
end

% Find expected profit given a click for each bid.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,1));
end

for h=1:hrs
    % get bid
    x_choice = logKG(X,w_est,q_est,10);
    bid = x_choice(1);
    bidIndex = find(X(:,1) == bid);
    % simulate number of auctions and clicks for the hour
    numAucts = poissrnd(auctions(h));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(bidIndex));
    % update estimates of w and q
    [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,numAucts,numClicks);
end

% graph to see error
figure;
alt = linspace(0,10)';
xX = [alt ones(length(alt),1)];
trueCurve = sigmoid(xX*wStar);
estCurve = sigmoid(xX*w_est);
h = plot(alt,trueCurve);
hold on;
plot(alt,estCurve);

[~,alt_best] = max(E_profit.*truth);
opt_bid = X(alt_best,1);
scatter(opt_bid,sigmoid([opt_bid 1]*wStar),[],get(h,'Color'),'*');
