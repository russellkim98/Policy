% Compares the knowledge gradient policy with a logistic regression belief
% model with a pure exploitation policy.

% historical data, max number of auctions per hour
oldFolder = cd;
cd ..;
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));
hrs = 168;
cd(oldFolder);

% Initialize policy
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
[~,alt_best] = max(E_profit.*truth);

% result matrices
KG_all = zeros(M,hrs);
reward_all = zeros(M,hrs);

for h=1:hrs
    % find KG and one-period rewards
    reward = E_profit.*sigmoid(X*w_est);
    [bidIndex,KG]=logKG(X,w_est,q_est);
    bid = X(bidIndex,2);
    
    % simulate number of auctions, clicks, and profit for the hour
    numAucts = poissrnd(auctions(h));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(bidIndex));
    
    % update estimates of w and q
    [X,w_est,q_est] = learner_logKG(X,w_est,q_est,bid,numAucts,numClicks);
    
    % store one-period reward and offline KG values
    for alt=1:M
        KG_all(alt,h) = KG(alt);
        reward_all(alt,h) = reward(alt);
    end   
end

figure;
surf(1:hrs,1:M,KG_all);
hold on;
%surf(1:hrs,1:M,reward_all);
title('One-period rewards and offline KG values for each alternative over time for logKG');
xlabel('Time in simulation (in hours)');
ylabel('Alternative');

% graph to see error
figure;
x = linspace(0,10)';
xX = [ones(length(x),1) x];
trueCurve = sigmoid(xX*wStar);
estCurve = sigmoid(xX*w_est);
h = plot(x,trueCurve);
hold on;
plot(x,estCurve);
opt_bid = X(alt_best,2);
scatter(opt_bid,sigmoid([1 opt_bid]*wStar),[],get(h,'Color'),'*');
