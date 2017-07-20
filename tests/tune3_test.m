% Another tuning module.

% historical data, max number of auctions per hour
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));
% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(length(disc),1) disc];
M = length(X);
% thetas we are deciding between
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);
% THE TRUTH
altTruth = 6;
thetaStar=theta(:,altTruth);
truth = phi(X*thetaStar);

% input
runs = 1;
tau = 1;
hrs = 168;
% result matrix
results = zeros(runs,hrs);

for r=1:runs
    [a,b,c] = initialize_KG();
    for i = 1:hrs
        [a,b,c,bid] = KG_ms(a,b,c,tau);
        numAucts = poissrnd(auctions(i));
        if numAucts > A
            numAucts = A;
        end
        bidIndex = find(X(:,2) == bid);
        numClicks = binornd(numAucts,truth(bidIndex));
        [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
        results(r,i) = c(altTruth);
        bid
    end
    r
end


figure;
for r=1:runs
    plot3(1:hrs,r*ones(1,hrs),results(r,:));
    hold on;
end
title('Belief of truth over time for pure exploitation');
xlabel('Time in simulation (in hours)');
ylabel('Runs');