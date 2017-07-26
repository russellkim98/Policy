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
theta = [-1.5 -2.5 -3.5 -4.5 -5.5 -8 -1.5 -2.5 -3.5 -1.5 -2.5 -3.5 -4.5 -5.5; ...
    1 1 1 1 1 1 0.75 0.75 0.75 1.5 1.5 1.5 1.5 1.5];
K = length(theta);
% THE TRUTH
altTruth = 6;
thetaStar = theta(:,altTruth);
truth = phi(X*thetaStar);

% input
tau = 10;
hrs = 168;
% result matrix
KG_all = zeros(M,hrs);
reward_all = zeros(M,hrs);

[a,b,c] = initialize_KG();
for i = 1:hrs
    [a,b,c,bid,KG,reward] = KG_ms(a,b,c,tau);
    numAucts = poissrnd(auctions(i));
    if numAucts > A
        numAucts = A;
    end
    bidIndex = find(X(:,2) == bid);
    numClicks = binornd(numAucts,truth(bidIndex));
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
    % store one-period reward and offline KG values
    for alt=1:M
        KG_all(alt,i) = KG(alt);
        reward_all(alt,i) = reward(alt);
    end
    i
end

figure;
surf(1:hrs,1:M,KG_all);
hold on;
surf(1:hrs,1:M,reward_all);
title(['One-period rewards and offline KG values for each alternative over time for tau = ',num2str(tau)]);
xlabel('Time (in hours)');
ylabel('Alternative');