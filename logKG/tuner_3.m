% A module to tune the logKG/init_logKG/learner_logKG policy for the tunable 
% parameter representing the time horizon, specifically auctions and clicks 
% coming from several locations. Graphs the average opportunity cost for 
% each value in t_hors. 
%
% For each run, starts off with normal prior distributions of the
% coefficients of the logistic function and tries to learn the true curves 
% with each value of the tunable parameter in t_hors. Simulates weeks on
% a per hour basis.
%
% For simplicity, assumes that there are x countries, x^2 regions (x regions 
% in every country), x^3 cities (x cities in every region). Assumes that the 
% first x cities (indices 1,2,..,x) are in the first region and the second 
% x cities (indices x+1,x+2,...,2x) are in the second region and so forth.
% Also assumes the same of regions and countries.

t_hors = 0:1:50;  % various time horizons to be tested
hrs = 168;        % # of hours in simulation
runs = 25;        % # of simulations (# of times each time horizon is tested)

global nCountries;
nCountries = 2;
nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;
numLocations = nCountries + nRegions + nCities; % # indicator variables

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% initialize policy
[X,~,~] = init_logKG(numLocations+1);
[M,~] = size(X);
OC_all = zeros(length(t_hors),1);

% Find expected profit given a click for each bid.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit2(X(alt,1));
end

for r=1:runs
    
    % randomly set a reasonable truth
    while 1
        % true coefficients for bid, countries, regions, and cities
        wStar = zeros(numLocations+1,1);
        wStar(1) = normrnd(0.75,1);
        for l=1:numLocations
            wStar(1+l) = normrnd(-2,1);
        end
        
        % initialize policy and set truths for each location
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
    
    for t=1:length(t_hors)
        % prior distributions of w_est and q_est
        [X,w_est,q_est] = init_logKG(numLocations+1);
        % opportunity cost over the whole week for this run/time horizon
        OC_week = 0;
        
        for h=1:hrs
            numAucts = poissrnd(auctions(h));
            for a=1:numAucts
                % randomly pick a location to set for the auction
                city = ceil(nCities*rand);
                [~,alt_best] = max(E_profit.*truth(city,:)');
                [X,~,~] = init_logKG(numLocations+1);
                X = location(X,city);
                % get bid for that auction
                x_choice = logKG(X,w_est,q_est,t_hors(t));
                bid = x_choice(1);
                bidIndex = find(X(:,1) == bid);
                % simulate click or not and update OC
                click = binornd(1,truth(city,bidIndex));
                OC_week = OC_week + binornd(1,truth(city,alt_best))*E_profit(alt_best) - click*E_profit(bidIndex);
                % update estimates of w and q
                [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,1,click);
            end
        end
        OC_all(t) = OC_all(t) + OC_week;
    end
    r
    
end

% Graph opportunity cost
figure;
OC_avg = OC_all/runs;
plot(t_hors,OC_avg);
title('Average weekly OC varying time horizon tunable parameter for logKG and 8 cities');
xlabel('Value of tunable parameter');
ylabel('OC over the week, averaged over 25 runs (in dollars)');