% Another tuning module for init_KG/KG_ms/learn_KG, which specifically
% begins with a truth that is much different from the rest to see how the 
% policy behaves and then graphs the one-period rewards and the offline KG
% values instead of profits or opportunity cost. 
%
% Note: To run this program, you have to change init_KG to initialize the
% various theta vectors to be the same as the ones listed in this program.
% You also have to modify KG_ms to not take in a t_hor tunable parameter
% and instead return both the one-period rewards vector (rewards) and the
% offline KG vector (KG). 

tau = 10;        % value of lookahead tunable parameter
hrs = 168;       % # of hours in simulation

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% alternatives that we are deciding between
[X,~,~] = init_KG;
M = length(X);

% thetas we are deciding between
theta = [-1.5 -2.5 -3.5 -4.5 -5.5 -8 -1.5 -2.5 -3.5 -1.5 -2.5 -3.5 -4.5 -5.5; ...
    1 1 1 1 1 1 0.75 0.75 0.75 1.5 1.5 1.5 1.5 1.5];
K = length(theta);

% THE TRUTH
altTruth = 6;
thetaStar = theta(:,altTruth);
truth = phi(X*thetaStar);

% result matrices
KG_all = zeros(M,hrs);
reward_all = zeros(M,hrs);

[a,b,c] = init_KG();
for i = 1:hrs
    [bid,KG,reward] = KG_ms(a,b,c,tau);
    numAucts = poissrnd(auctions(i));
    bidIndex = find(X(:,2) == bid);
    numClicks = binornd(numAucts,truth(bidIndex));
    [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
    % store one-period reward and offline KG values
    KG_all(:,i) = KG;
    reward_all(:,i) = reward;
    i
end

figure;
surf(1:hrs,1:M,KG_all);
hold on;
surf(1:hrs,1:M,reward_all);
title(['One-period rewards and offline KG values for each alternative over time for tau = ',num2str(tau)]);
xlabel('Time (in hours)');
ylabel('Alternative');