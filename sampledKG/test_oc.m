% A module to test the behavior of KG_ms, specifically by graphing the 
% opportunity cost of the policy as a function of the number of steps in 
% the simulation. Simulates a week on a per hour basis.

% historical data, max number of auctions per hour
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));
% alternatives that we are deciding between
disc = (0:0.5:10)';
X = [ones(length(disc),1) disc];
M = length(X);
% thetas we are deciding between
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);

% input
t_hor = 100;
tau = 5;
hrs = 168;
OC_all = zeros(hrs,1);
runs = 25;

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
    [a,b,c] = initialize_KG();
    for i = 1:hrs
        [a,b,c,bid] = KG_ms(a,b,c,t_hor,tau);
        numAucts = poissrnd(auctions(i));
        if numAucts > A
            numAucts = A;
        end
        bidIndex = find(X(:,2) == bid);
        numClicks = binornd(numAucts,truth(bidIndex));
        OC_all(i) = OC_all(i) + binornd(numAucts,truth(alt_best))*E_profit(alt_best) - numClicks*E_profit(bidIndex);
        [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
    end
    r
end

% Graph opportunity cost
figure;
OC_avg = OC_all/runs;
plot(1:hrs,OC_avg);
title('Average OC over time in simulation using KG_ms (t_hor = 100, tau = 5)');
xlabel('Time in simulation (in hours)');
ylabel('OC, averaged over 25 runs (in dollars)');
