% Another tuning module for init_KG/KG_ms/learn_KG, which specifically
% toggles between two groups of true theta vectors that are fairly
% different from one another and graphs the one-period rewards and the
% offline KG values instead of profits or opportunity cost. 
%
% Note: To run this program, you have to change init_KG to initialize the
% various theta vectors to be the same as the ones listed in this program.
% You also have to modify KG_ms to not take in a t_hor tunable parameter
% and instead return both the one-period rewards vector (rewards) and the
% offline KG vector (KG). 

tau = 10;        % value of lookahead tunable parameter
hrs = 72;        % # of hours in simulation

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% alternatives that we are deciding between
[X,~,~] = init_KG;
M = length(X);

% thetas we are deciding between
theta = [-1.5 -2.5 -1.5 -2.5     -9 -10 -4.5 -5.5; ...
          1 1 1.5 1.5              1 1 0.5 0.5];
theta_grp = [1 1 1 1 3 3 3 3];
K = length(theta);
altTruth = [6; 3; 6; 3; 6; 3; 6; 3; 6; 3; 6];
thetaStar = theta(:,altTruth(1));
truth = phi(X*thetaStar);

[a,b,c] = init_KG();
KG_all = zeros(M,hrs);
reward_all = zeros(M,hrs);
for i = 1:hrs
    % toggle truth every 15 hours
    if mod(i,15) == 0
        n = idivide(i,int32(15));
        thetaStar = theta(:,altTruth(n+1));
        truth = phi(X*thetaStar);
    end
    % regular simulation
    [bid,KG,reward] = KG_ms(a,b,c,tau);
    numAucts = poissrnd(auctions(i));
    bidIndex = find(X(:,2) == bid);
    numClicks = binornd(numAucts,truth(bidIndex));
    [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
    % store one-period reward and offline KG values
    KG_all(:,i) = KG;
    reward_all(:,i) = reward;
end

figure;
surf(1:hrs,1:M,KG_all);
hold on;
surf(1:hrs,1:M,reward_all);
title(['One-period rewards and offline KG values for each alternative over time for tau = ',num2str(tau)]);
xlabel('Time (in hours)');
ylabel('Alternative');
