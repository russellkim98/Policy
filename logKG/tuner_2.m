% A module to tune the logKG/init_logKG/learner_logKG policy for the tunable 
% parameter representing the time horizon, specifically with a changing truth. 
% Graphs the average opportunity cost for each value in t_hors. 
%
% For each run, starts off with a normal prior distribution of the
% coefficients of the logistic function and tries to learn the true curve 
% with each value of the tunable parameter in t_hors. Simulates weeks on
% a per hour basis, with the truth changing at each hour with a set
% probability.

t_hors = 0:1:50;  % various time horizons to be tested
hrs = 168;        % # of hours in simulation
runs = 25;        % # of simulations (# of times each time horizon is tested)
probChange = 0.1; % probability of changing truth for a given step

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% initialize policy
[X,~,~] = init_logKG(2);
X(:,2) = 1;
[M,~] = size(X);
OC_all = zeros(length(t_hors),1);

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit2(X(alt,1));
end

for r=1:runs    
    for t=1:length(t_hors)
        
        % prior distributions of w_est and q_est
        [X,w_est,q_est] = init_logKG(2);
        X(:,2) = 1;
        % opportunity cost over the whole week for this run/time horizon
        OC_week = 0;
        
        % randomly set a reasonable truth
        while 1
            wStar_0 = normrnd(-7,1);
            wStar_1 = normrnd(1,1);
            wStar=[wStar_1;wStar_0];
            truth=sigmoid(X*wStar);
            [~,alt_best] = max(E_profit.*truth);
            if truth(M) > 0.1
                break
            end
        end
        
        for h=1:hrs
            % occasionally change to another randomized, reasonable truth
            if binornd(1,probChange) == 1
                while 1
                    wStar_0 = normrnd(-7,1);
                    wStar_1 = normrnd(1,1);
                    wStar=[wStar_1;wStar_0];
                    truth=sigmoid(X*wStar);
                    [~,alt_best] = max(E_profit.*truth);
                    if truth(M) > 0.1
                        break
                    end
                end
            end
            % get bid
            x_choice = logKG(X,w_est,q_est,t_hors(t));
            bid = x_choice(1);
            bidIndex = find(X(:,1) == bid);
            % simulate number of auctions, clicks, and OC for the hour
            numAucts = poissrnd(auctions(h));
            numClicks = binornd(numAucts,truth(bidIndex));
            OC_week = OC_week + binornd(numAucts,truth(alt_best))*E_profit(alt_best) - numClicks*E_profit(bidIndex);
            % update estimates of w and q
            [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,numAucts,numClicks);
        end
        OC_all(t) = OC_all(t) + OC_week;
        
    end
    r  
end

% graph average opportunity cost for each time horizon
figure;
OC_avg = OC_all/runs;
plot(t_hors,OC_avg);
title('Average weekly OC varying time horizon tunable parameter for logKG (transient truth)');
xlabel('Value of tunable parameter');
ylabel('OC over the week, averaged over 25 runs (in dollars)');