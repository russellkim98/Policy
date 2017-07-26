% A module to test logKG/init_logKG/learner_logKG, specifically with
% auctions and clicks coming from 2 distinct locations. Simulates a week on
% a per hour basis. Starts off with a normal prior distribution of the
% coefficients of the logistic function and tries to learn the true curve
% with an online logKG policy. 

hrs = 168;        % Number of steps in each simulation
numLocations = 2; % Number of location indicator variables

% Mean number of auctions per hour of week
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% The true coefficients, for the bid, location 1, and location 2
wStar = zeros(numLocations+1,1);
wStar(1) = normrnd(1,1);
wStar(2) = normrnd(-8,1);
wStar(3) = normrnd(-4,1);
wStar

% Initialize policy and set truths for each location
[X,w_est,q_est] = init_logKG(numLocations+1);
[M,~] = size(X);
truth = zeros(numLocations,M);
for loc=1:numLocations
    [X,~,~] = init_logKG(numLocations+1);
    X(:,loc+1) = 1;
    truth(loc,:) = sigmoid(X*wStar);
end

% Find expected profit given a click for each bid.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,1));
end

for h=1:hrs
    % randomly pick a location to set for the hour
    loc = ceil(numLocations*rand);
    [X,~,~] = init_logKG(numLocations+1);
    X(:,loc+1) = 1;
    % get bid
    [x_choice,w_est,q_est] = logKG(X,w_est,q_est,10);
    bid = x_choice(1);
    bidIndex = find(X(:,1) == bid);
    % simulate number of auctions and clicks for the hour
    numAucts = poissrnd(auctions(h));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(loc,bidIndex));
    % update estimates of w and q
    [w_est,q_est] = learner_logKG(x_choice,w_est,q_est,numAucts,numClicks);
end

% graph to see error
figure;
alt = linspace(0,10)';
for loc=1:numLocations
    xX = [alt zeros(length(alt),numLocations)];
    xX(:,loc+1) = 1;
    trueCurve = sigmoid(xX*wStar);
    estCurve = sigmoid(xX*w_est);
    h = plot(alt,trueCurve);
    hold on;
    plot(alt,estCurve,'--','Color',get(h,'Color'));
end

% [~,alt_best] = max(E_profit.*truth);
% opt_bid = X(alt_best,1);
% scatter(opt_bid,sigmoid([opt_bid 1]*wStar),[],get(h,'Color'),'*');


