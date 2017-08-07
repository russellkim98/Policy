% Tunes the logKG/init_logKG/learner_logKG policy for the tunable parameter
% representing the time horizon (the parameter in front of the offline KG
% value in the online calculation). For each run, a truth is set and then
% for each possible value in t_hors, this test file simulates a week
% on a per hour basis. Displays the average opportunity cost for each
% value in t_hors over the number of runs. This tuner specifically
% incorporates the location attributes (auctions/clicks coming from a
% number of locations). 

global nCountries;
nCountries = 6;

nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;
numLocations = nCountries + nRegions + nCities; % # of indicator variables
t_hors = 0:25:500;     % Various time horizons to be tested
runs = 15;          % # of times each time horizon is tested
hrs = 168;          % Number of steps in each simulation

% Mean number of auctions per hour of week
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% Initialize policy
[X,~,~] = init_logKG(numLocations+1);
[M,~] = size(X);
OC_all = zeros(length(t_hors),1);

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
    
    for t=1:length(t_hors)
        % prior distributions of w_est and q_est
        [X,w_est,q_est] = init_logKG(numLocations+1);
        % opportunity cost over the whole week for this truth/time horizon
        OC_week = 0;
        
        for h=1:hrs
            % simulate number of auctions for the hour
            numAucts = poissrnd(auctions(h));
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
                [x_choice,w_est,q_est] = logKG(X,w_est,q_est,t_hors(t));
                bid = x_choice(1);
                bidIndex = find(X(:,1) == bid);
                % simulate click or not and update OC
                click = binornd(1,truth(city,bidIndex));
                OC_week = OC_week + binornd(1,truth(city,alt_best))*E_profit(alt_best) - click*E_profit(bidIndex);
                % update estimates of w and q
                [w_est,q_est] = learner_logKG(x_choice,w_est,q_est,1,click);
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
title('Average weekly OC varying time horizon tunable parameter for logKG');
xlabel('Value of tunable parameter');
ylabel('OC over the week, averaged over 15 runs (in dollars)');

function altMatrix = location(altMatrix,city)

global nCountries;
nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;

country = idivide((city - 1),int32(nCities/nCountries)) + 1;
region = idivide((city - 1),int32(nCities/nRegions)) + 1;
altMatrix(:,1+country) = 1;
altMatrix(:,1+nCountries+region) = 1;
altMatrix(:,1+nCountries+nRegions+city) = 1;

end
