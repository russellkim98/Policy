% Tunes the logKG/init_logKG/learner_logKG policy for the tunable parameter
% representing the time horizon (the parameter in front of the offline KG
% value in the online calculation). For each run, a truth is set and then
% for each possible value in t_hors, this test file simulates a week
% on a per hour basis. Each week, the truth is changed 3 times. Displays 
% the average opportunity cost for each value in t_hors over the number of runs.

t_hors = 0:0.5:25;  % Various time horizons to be tested
runs = 25;        % # of times each time horizon is tested
hrs = 168;        % Number of steps in each simulation
probChange = 0.1; % Probability of changing truth for a given step

% Mean number of auctions per hour of week
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% Initialize policy
[X,w_est,q_est] = init_logKG();
[M,d] = size(X);
OC_all = zeros(length(t_hors),1);

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,:));
end

for r=1:runs    
    for t=1:length(t_hors)
        
        % prior distributions of w_est and q_est
        [X,w_est,q_est] = init_logKG();
        % opportunity cost over the whole week for this truth/time horizon
        OC_week = 0;
        
        % Set a reasonable truth
        while 1
            wStar_0 = normrnd(-7,1);
            wStar_1 = normrnd(1,1);
            wStar=[wStar_0;wStar_1];
            truth=sigmoid(X*wStar);
            [~,alt_best] = max(E_profit.*truth);
            if truth(M) > 0.1
                break
            end
        end
        
        for h=1:hrs
            % Change to another reasonable truth
            if binornd(1,probChange) == 1
                while 1
                    wStar_0 = normrnd(-7,1);
                    wStar_1 = normrnd(1,1);
                    wStar=[wStar_0;wStar_1];
                    truth=sigmoid(X*wStar);
                    [~,alt_best] = max(E_profit.*truth);
                    if truth(M) > 0.1
                        break
                    end
                end
            end
            % get bid
            [X,w_est,q_est,bid]=logKG(X,w_est,q_est,t_hors(t));
            bidIndex = find(X(:,2) == bid);
            % simulate number of auctions, clicks, and OC for the hour
            numAucts = poissrnd(auctions(h));
            if numAucts > A
                numAucts = A;
            end
            numClicks = binornd(numAucts,truth(bidIndex));
            OC_week = OC_week + binornd(numAucts,truth(alt_best))*E_profit(alt_best) - numClicks*E_profit(bidIndex);
            % update estimates of w and q
            [X,w_est,q_est] = learner_logKG(X,w_est,q_est,bid,numAucts,numClicks);
        end
        OC_all(t) = OC_all(t) + OC_week;
    end
    
    r
    
end

% Graph opportunity cost
figure;
OC_avg = OC_all/runs;
plot(t_hors,OC_avg);
title('Average weekly OC varying time horizon tunable parameter for logKG (transient truth)');
xlabel('Value of tunable parameter');
ylabel('OC over the week, averaged over 25 runs (in dollars)');