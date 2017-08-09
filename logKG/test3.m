% A module to test logKG/init_logKG/learner_logKG, specifically with 
% auctions and clicks coming from several locations. 
%
% Starts off with normal prior distributions of the coefficients of the 
% logistic function and tries to learn the true curves with an online logKG 
% policy with a tunable parameter value of 10. Simulates a week on a per 
% hour basis. Graphs the true and estimated curves. 
%
% For simplicity, assumes that there are x countries, x^2 regions (x regions 
% in every country), x^3 cities (x cities in every region). Assumes that the 
% first x cities (indices 1,2,..,x) are in the first region and the second 
% x cities (indices x+1,x+2,...,2x) are in the second region and so forth.
% Also assumes the same of regions and countries.

t_hor = 10;       % value of time horizon tunable parameter
hrs = 168;        % # of hours in simulation

global nCountries;
nCountries = 2;
nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;
numLocations = nCountries + nRegions + nCities; % # indicator variables

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% randomly set a reasonable truth
while 1
    
    % true coefficients for bid, countries, regions, and cities
    wStar = zeros(numLocations+1,1);
    wStar(1) = normrnd(0.75,1);
    for c=1:nCountries
        wStar(1+c) = normrnd(-1,1);
    end
    for r=1:nRegions
        wStar(1+nCountries+r) = normrnd(-2,1);
    end
    for c=1:nCities
        wStar(1+nCountries+nRegions+c) = normrnd(-3,1);
    end
    
    % initialize policy and set truths for each location
    [X,w_est,q_est] = init_logKG(numLocations+1);
    [M,~] = size(X);
    truth = zeros(nCities,M);
    for city=1:nCities
        % gets a blank alternative matrix
        [X,~,~] = init_logKG(numLocations+1);
        % turns "on" indicator variables according to location
        X = location(X,city);
        truth(city,:) = sigmoid(X*wStar);
    end
    if sum(truth(:,M) < 0.01) == 0
        break;
    end
end

% Find expected profit given a click for each bid.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit2(X(alt,1));
end

for h=1:hrs
    numAucts = poissrnd(auctions(h));
    for a=1:numAucts
        % randomly pick a location to set for the auction
        city = ceil(nCities*rand);
        [X,~,~] = init_logKG(numLocations+1);
        X = location(X,city);
        % get bid for that auction
        x_choice = logKG(X,w_est,q_est,t_hor);
        bid = x_choice(1);
        bidIndex = find(X(:,1) == bid);
        % simulate click or not
        click = binornd(1,truth(city,bidIndex));
        % update estimates of w and q
        [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,1,click);
    end
end

figure;
alt = linspace(0,10)';
for city = 1:nCities
    
    xX = [alt zeros(length(alt),numLocations)];
    xX = location(xX,city);
    
    % graph true and estimated curves
    trueCurve = sigmoid(xX*wStar);
    estCurve = sigmoid(xX*w_est);
    h = plot(alt,trueCurve);
    hold on;
    plot(alt,estCurve,'--','Color',get(h,'Color'));
    
    % plot optimal bid on true probability curve
    [~,alt_best] = max(E_profit.*truth(city,:)');
    opt_bid = X(alt_best,1);
    opt_alt = [opt_bid zeros(1,numLocations)];
    opt_alt = location(opt_alt,city);
    opt_prob = sigmoid(opt_alt*wStar);
    scatter(opt_bid,opt_prob,[],get(h,'Color'),'*');
    
end