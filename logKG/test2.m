% The simplest module to test logKG/init_logKG/learn_logKG. 
%
% Starts off with a normal prior distribution of the coefficients of the 
% logistic function and tries to learn the true curve with an online logKG 
% policy with a tunable parameter value of 10. Simulates a week on a per 
% hour basis. Graphs the true curve and the estimated curve. 

t_hor = 10;       % value of time horizon tunable parameter
hrs = 168;        % # of hours in simulation

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% initialize policy
[X,w_est,q_est] = init_logKG(2);
X(:,2) = 1;
[M,~] = size(X);

% randomly set a reasonable truth
while 1
    wStar_0 = normrnd(-7,1); % coefficient for constant
    wStar_1 = normrnd(1,1);  % coefficient for bid value
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
    x_choice = logKG(X,w_est,q_est,t_hor);
    bid = x_choice(1);
    bidIndex = find(X(:,1) == bid);
    % simulate number of auctions and clicks for the hour
    numAucts = poissrnd(auctions(h));
    numClicks = binornd(numAucts,truth(bidIndex));
    % update estimates of w and q
    [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,numAucts,numClicks);
end

% graph true and estimated curves
figure;
alt = linspace(0,10)';
xX = [alt ones(length(alt),1)];
trueCurve = sigmoid(xX*wStar);
estCurve = sigmoid(xX*w_est);
h = plot(alt,trueCurve);
hold on;
plot(alt,estCurve);

% plot optimal bid on true probability curve
[~,alt_best] = max(E_profit.*truth);
opt_bid = X(alt_best,1);
scatter(opt_bid,sigmoid([opt_bid 1]*wStar),[],get(h,'Color'),'*');
