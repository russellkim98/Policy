% A module to test the behavior of logKG/init_logKG/learner_logKG.
% Graphs the reward per time period versus the cumulative reward.
%
% Starts off with a normal prior distribution of the coefficients of the 
% logistic function and tries to learn the true curve with an online logKG 
% policy with a tunable parameter value of 10. Simulates a week on a per 
% hour basis.

t_hor = 10;       % value of time horizon tunable parameter
hrs = 168;        % # of hours in simulation
runs = 1;         % # of simulations

global nCountries;
nCountries = 6;
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
reward_hr = zeros(hrs,1);
reward_sum = zeros(hrs,1);

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
    
    % prior distributions of w_est and q_est
    [X,w_est,q_est] = init_logKG(numLocations+1);
    
    for h=1:hrs
        numAucts = poissrnd(auctions(h));
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
            reward_hr(h) = reward_hr(h) + click*E_profit(bidIndex);
            % update estimates of w and q
            [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,1,click);
        end
    end
    
    r
    
end


% graph reward versus cumulative reward for each hour
reward_avg = reward_hr/runs;
reward_sum(1) = reward_avg(1);
for h=2:hrs
    reward_sum(h) = reward_sum(h-1) + reward_avg(h);
end
figure;
plot(1:hrs,reward_avg);
hold on;
plot(1:hrs,reward_sum);
title('Reward Over Time in Simulation');
xlabel('Time in Simulation (in Hours)');
ylabel('Reward (in Dollars)');
legend('Hourly Reward','Cumulative Reward');