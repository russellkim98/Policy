% Tunes the logKG/init_logKG/learner_logKG policy for the tunable parameter
% representing the time horizon (the parameter in front of the offline KG
% value in the online calculation). For each run, a truth is set and then
% for each possible value in t_hors, this test file simulates a week
% on a per hour basis. Displays the average opportunity cost for each
% value in t_hors over the number of runs. This tuner specifically
% incorporates the location attributes (auctions/clicks coming from
% distinct locations).

t_hors = 0:25:1000; % Various time horizons to be tested
runs = 25;          % # of times each time horizon is tested
hrs = 168;          % Number of steps in each simulation
numLocations = 5;   % Number of location indicator variables

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
        wStar = zeros(numLocations+1,1);
        wStar(1) = normrnd(1,1);
        wStar(2) = normrnd(-8,1);
        wStar(3) = normrnd(-7,1);
        wStar(4) = normrnd(-6,1);
        wStar(5) = normrnd(-5,1);
        wStar(6) = normrnd(-4,1);
        % Initialize policy and set truths for each location
        [X,~,~] = init_logKG(numLocations+1);
        truth = zeros(numLocations,M);
        for loc=1:numLocations
            [X,~,~] = init_logKG(numLocations+1);
            X(:,loc+1) = 1;
            truth(loc,:) = sigmoid(X*wStar);
        end
        if sum(truth(:,M) < 0.1) == 0
            break;
        end
    end
    
    for t=1:length(t_hors)
        % prior distributions of w_est and q_est
        [X,w_est,q_est] = init_logKG(numLocations+1);
        % opportunity cost over the whole week for this truth/time horizon
        OC_week = 0;
        
        for h=1:hrs
            % randomly pick a location to set for the hour
            loc = ceil(numLocations*rand);
            [~,alt_best] = max(E_profit.*truth(loc,:)');
            [X,~,~] = init_logKG(numLocations+1);
            X(:,loc+1) = 1;
            % get bid
            [x_choice,w_est,q_est] = logKG(X,w_est,q_est,t_hors(t));
            bid = x_choice(1);
            bidIndex = find(X(:,1) == bid);
            % simulate number of auctions, clicks, and OC for the hour
            numAucts = poissrnd(auctions(h));
            if numAucts > A
                numAucts = A;
            end
            numClicks = binornd(numAucts,truth(loc,bidIndex));
            OC_week = OC_week + binornd(numAucts,truth(loc,alt_best))*E_profit(alt_best) - numClicks*E_profit(bidIndex);
            
            % update estimates of w and q
            [w_est,q_est] = learner_logKG(x_choice,w_est,q_est,numAucts,numClicks);
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
ylabel('OC over the week, averaged over 25 runs (in dollars)');
