% A module to test the behavior of logKG/init_logKG/learner_logKG,
% specifically by graphing the opportunity cost of the policy as a function
% of the number of steps in the simulation. Simulates a week on a per hour
% basis, specifically with auctions and clicks coming from distinct locations.
% Starts off with a normal prior  distribution of the coefficients of the
% logistic function and tries to learn the true curve with an online logKG
% policy.

global nCountries;
nCountries = 2;

nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;
numLocations = nCountries + nRegions + nCities; % # of indicator variables
t_hor = 10;  % value of the time horizon tunable parameter
runs = 15;   % # of times each time horizon is tested
hrs = 336;   % number of steps in each simulation

% Mean number of auctions per hour of week
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% Initialize policy
[X,~,~] = init_logKG(numLocations+1);
[M,~] = size(X);
OC_all = zeros(hrs,1);

% Find expected profit given a click for each bid.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,1));
end

for r=1:runs
    % Set a reasonable truth
    while 1
        % True coefficients for bid, countries, regions, and cities
        wStar = zeros(numLocations+1,1);
        wStar(1) = normrnd(0.75,1);
        for c=1:nCountries
            wStar(1+c) = normrnd(-1,1);
        end
        for g=1:nRegions
            wStar(1+nCountries+g) = normrnd(-2,1);
        end
        for c=1:nCities
            wStar(1+nCountries+nRegions+c) = normrnd(-3,1);
        end
        
        % Initialize policy and set truths for each location
        truth = zeros(nCities,M);
        for city=1:nCities
            [X,~,~] = init_logKG(numLocations+1);
            X = location(X,city);
            truth(city,:) = sigmoid(X*wStar);
        end
        if sum(truth(:,M) < 0.01) == 0
            break;
        end
    end
    
    % prior distributions of w_est and q_est
    [X,w_est,q_est] = init_logKG(numLocations+1);
    
    for h=1:hrs
        % simulate number of auctions for the hour
        hour_of_week = mod(h-1,168) + 1;
        numAucts = poissrnd(auctions(hour_of_week));
        if numAucts > A
            numAucts = A;
        end
        for a=1:numAucts
            % randomly pick a location to set for the auction
            city = ceil(nCities*rand);
            [~,alt_best] = max(E_profit.*truth(city,:)');
            [X,~,~] = init_logKG(numLocations+1);
            X = location(X,city);
            % get bid for that auction
            x_choice = logKG(X,w_est,q_est,t_hor);
            bid = x_choice(1);
            bidIndex = find(X(:,1) == bid);
            % simulate click or not and update OC
            click = binornd(1,truth(city,bidIndex));
            OC_all(h) = OC_all(h) + binornd(1,truth(city,alt_best))*E_profit(alt_best) - click*E_profit(bidIndex);
            % update estimates of w and q
            [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,1,click);
        end
    end
    r
end

% Graph opportunity cost
figure;
OC_avg = OC_all/runs;
plot(1:hrs,OC_avg);
title('Average OC over time in simulation for 1000 cities using logKG');
xlabel('Time in simulation (in hours)');
ylabel('OC, averaged over 15 runs (in dollars)');