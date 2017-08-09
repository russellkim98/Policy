% Another attempt at tuning the number of auctions tau to look ahead and the
% time horizon in the online version of the multi-step look-ahead KG
% policy. Runs a week-long simulation for a given number of taus, comparing
% the one-period reward and the offline KG value for each.

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
theta = [-1.5 -2.5 -1.5 -2.5     -9 -10 -4.5 -5.5; ...
          1 1 1.5 1.5              1 1 0.5 0.5];
theta_grp = [1 1 1 1 3 3 3 3];
K = length(theta);

% THE TRUTH
% altTruth = ceil(rand*K);
% thetaStar = theta(:,altTruth);
% truth = phi(X*thetaStar);

altTruth = [6; 3; 6; 3; 6; 3; 6; 3; 6; 3; 6];
thetaStar = theta(:,altTruth(1));
truth = phi(X*thetaStar);

% input
tau = 10;
hrs = 72;

% Tuning
[a,b,c] = init_KG();
KG_all = zeros(M,hrs);
reward_all = zeros(M,hrs);
for i = 1:hrs
    
    %     if mod(i,10) == 0
    %         disp(altTruth);
    %         altNewTruth = ceil(rand*K);
    %         while theta_grp(altNewTruth) == theta_grp(altTruth)
    %             altNewTruth = ceil(rand*K);
    %         end
    %         altTruth = altNewTruth;
    %         thetaStar = theta(:,altTruth);
    %         truth = phi(X*thetaStar);
    %         disp(altTruth);
    %     end
    
    % change truth every 15 hours
    if mod(i,15) == 0
        n = idivide(i,int32(15));
        thetaStar = theta(:,altTruth(n+1));
        truth = phi(X*thetaStar);
    end
    
    % regular simulation
    [bid,KG,reward] = KG_ms(a,b,c,tau);
    numAucts = poissrnd(auctions(i));
    if numAucts > A
        numAucts = A;
    end
    bidIndex = find(X(:,2) == bid);
    numClicks = binornd(numAucts,truth(bidIndex));
    [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
    % store one-period reward and offline KG values
    KG_all(:,i) = KG;
    reward_all(:,i) = reward;
    
    disp(c);
    disp(KG);
    disp(bid);
    
end

figure;
surf(1:hrs,1:M,KG_all);
hold on;
surf(1:hrs,1:M,reward_all);
title(['One-period rewards and offline KG values for each alternative over time for tau = ',num2str(tau)]);
xlabel('Time (in hours)');
ylabel('Alternative');