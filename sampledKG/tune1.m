% The simplest tuning module for init_KG/KG_ms/learn_KG, which
% simulataneously tunes the number of auctions tau to look ahead and the
% time horizon in the online version of the multi-step look-ahead KG
% policy. 
%
% Runs a week-long simulation for each possible tau/time-horizon
% combination from a sample given and then plots the opportunity cost for
% all of those policies. 

taus = [1 5 10 15 20];     % various values of lookahead tunable parameter to test
t_hors = [0 10 100 1000];  % various values of time horizon tunable parameter to test
hrs = 168;                 % # of hours in simulation

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% initialize policy
[X,theta,~] = init_KG;
M = length(X);
K = length(theta);

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,:));
end

% the truth
altTruth = randi(K);
thetaStar = theta(:,altTruth);
truth = phi(X*thetaStar);
[~,alt_best] = max(E_profit.*truth);

% result matrices
truth_all = zeros(length(taus),length(t_hors));
policy_all = zeros(length(taus),length(t_hors));

for indexH=1:length(t_hors)
    for indexT=1:length(taus)
        
        [a,b,c] = init_KG();
        
        % profit over the whole week using truth
        truth_week = 0;
        % profit over the whole week when using policy
        policy_week = 0;
        
        % step through a simulation for this tau/t_hor combination
        for i = 1:hrs
            bid = KG_ms(a,b,c,t_hors(indexH),taus(indexT));
            numAucts = poissrnd(auctions(i));
            if numAucts > A
                numAucts = A;
            end
            bidIndex = find(X(:,2) == bid);
            numClicks = binornd(numAucts,truth(bidIndex));
            % capture profits
            truth_week = truth_week + binornd(numAucts,truth(alt_best))*E_profit(alt_best);
            policy_week = policy_week + numClicks*E_profit(bidIndex);
            % update policy
            [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
        end
        truth_all(indexT,indexH) = truth_all(indexT,indexH) + truth_week;
        policy_all(indexT,indexH) = policy_all(indexT,indexH) + policy_week;
    end
    indexH
end

figure;
OC_all = truth_all - policy_all;
surf(t_hors,taus,OC_all);
title('OC varying online tunable parameter and time periods to look ahead');
xlabel('Time horizon (online)');
ylabel('Time periods to look ahead');
