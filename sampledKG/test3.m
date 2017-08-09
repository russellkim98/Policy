% A module to test the behavior of KG_ms/init_KG/learn_KG, specifically by 
% graphing the opportunity cost of the policy as a function of the number 
% of steps in the simulation.
%
% For each run, starts off believing each possible theta vector is equally 
% likely to be the true vector and tries to learn the true curve with an 
% online logKG policy. Runs a simulation by hour-by-hour but specifically
% calls KG_ms and learn_KG for each auction. Averages the OC value for each
% hour over the number of runs. 

t_hor = 100;     % value of time horizon tunable parameter
tau = 5;         % value of lookahead tunable parameter
hrs = 168;       % # of hours in simulation
runs = 15;       % # of simulations

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% initialize policy
[X,theta,p] = init_KG();
M = length(X);
K = length(theta);

% result matrix
OC_all = zeros(hrs,1);

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,:));
end

for r=1:runs
    % the truth
    altTruth = randi(K);
    thetaStar = theta(:,altTruth);
    truth = phi(X*thetaStar);
    [~,alt_best] = max(E_profit.*truth);
    % week-long simulation
    [a,b,c] = init_KG();
    for i = 1:hrs
        numAucts = poissrnd(auctions(i));
        for auct=1:numAucts
            bid = KG_ms(a,b,c,t_hor,tau);
            bidIndex = find(X(:,2) == bid);
            numClicks = binornd(1,truth(bidIndex));
            OC_all(i) = OC_all(i) + binornd(1,truth(alt_best))*E_profit(alt_best) - numClicks*E_profit(bidIndex);
            [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
            i
        end
    end
    r
end

% graph opportunity cost
figure;
OC_avg = OC_all/runs;
plot(1:hrs,OC_avg);
title('Average OC over time in simulation using KG_ms (t_hor = 100, tau = 5)');
xlabel('Time in simulation (in hours)');
ylabel('OC, averaged over 15 runs (in dollars)');
