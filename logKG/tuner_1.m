% The simplest module to tune the logKG/init_logKG/learner_logKG policy 
% for the tunable parameter representing the time horizon. Graphs the
% policy's average profits for each time horizon with the average profits
% if you knew the truth and if you randomly and uniformly chose a bid at
% each hour. 
% 
% For each run, starts off with a normal prior distribution of the
% coefficients of the logistic function and tries to learn the true curve 
% with each value of the tunable parameter in t_hors. Simulates weeks on
% a per hour basis.

t_hors = 0:1:50;  % various time horizons to be tested
hrs = 168;        % # of hours in simulation
runs = 25;        % # of simulations (# of times each time horizon is tested)

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% initialize policy
[X,~,~] = init_logKG(2);
X(:,2) = 1;
[M,~] = size(X);
pure_all = zeros(length(t_hors),1); 
rand_all = zeros(length(t_hors),1);
profit_all = zeros(length(t_hors),1);

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit2(X(alt,1));
end

for r=1:runs
    % randomly set a reasonable truth
    while 1
        wStar_0 = normrnd(-7,1); % coefficient for constant
        wStar_1 = normrnd(1,1);  % coefficient for bid value
        wStar=[wStar_1;wStar_0];
        truth=sigmoid(X*wStar);
        [~,alt_best] = max(E_profit.*truth);
        if truth(M) > 0.1
            break
        end
    end
    
    for t=1:length(t_hors)
        % prior distributions of w_est and q_est
        [X,w_est,q_est] = init_logKG(2);
        X(:,2) = 1;
        
        % profit over the whole week using truth
        pure_week = 0;
        % profit over the whole week when randomly choosing bid
        rand_week = 0;
        % profit over the whole week when using policy
        profit_week = 0;
        
        for h=1:hrs
            % get bid
            x_choice = logKG(X,w_est,q_est,t_hors(t));
            bid = x_choice(1);
            bidIndex = find(X(:,1) == bid);
            % simulate number of auctions and clicks for the policy
            numAucts = poissrnd(auctions(h));
            numClicks = binornd(numAucts,truth(bidIndex));
            % capture profits 
            pure_week = pure_week + binornd(numAucts,truth(alt_best))*E_profit(alt_best);
            alt_rand = randi(M);
            rand_week = rand_week + binornd(numAucts,truth(alt_rand))*E_profit(alt_rand);
            profit_week = profit_week + numClicks*E_profit(bidIndex);
            % update estimates of w and q
            [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,numAucts,numClicks);
        end
        pure_all(t) = pure_all(t) + pure_week;
        rand_all(t) = rand_all(t) + rand_week;
        profit_all(t) = profit_all(t) + profit_week;
    end
    
    r
    
end

% graph average profits for each time horizon
figure;
pure_avg = pure_all/runs;
rand_avg = rand_all/runs;
profit_avg = profit_all/runs;
plot(t_hors,pure_avg);
hold on;
plot(t_hors,rand_avg);
plot(t_hors,profit_avg);
title('Average weekly profits (over 25 runs) varying time horizon tunable parameter');
xlabel('Value of tunable parameter');
ylabel('Dollars');
legend('Knowing truth','Uniformly at random','logKG')