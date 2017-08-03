% Simulatenously tunes the number of auctions tau to look ahead and the
% time horizon in the online version of the multi-step look-ahead KG
% policy. Runs a week-long simulation for each possible tau/time horizon
% combination.

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
theta = [-1.5 -2.5 -3.5 -4.5 -5.5 -10 -1.5 -2.5 -3.5 -1.5 -2.5 -3.5 -4.5 -5.5; ...
    1 1 1 1 1 1 0.75 0.75 0.75 1.5 1.5 1.5 1.5 1.5];
K = length(theta);

% input
taus = [1 5 10 15 20];
t_hors = [0 10 100 1000];
hrs = 168;

% each simulation sees the same changing truths
% numChanges = idivide(hrs,int32(10));
% altTruth = zeros(numChanges+1,1);
% altTruth(1) = ceil(rand*K);
% for n=1:numChanges
%     altTruth(n+1) = ceil(rand*K);
%     while theta_grp(altTruth(n)) == theta_grp(altTruth(n+1))
%         altTruth(n+1) = ceil(rand*K);
%     end
% end
% altTruth = [14; 10; 13; 10; 12; 7; 4; 5];

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,:));
end

% the truth
altTruth = 6;
thetaStar = theta(:,altTruth);
truth = phi(X*thetaStar);
[~,alt_best] = max(E_profit.*truth);

% result matrices
truth_all = zeros(length(taus),length(t_hors));
rand_all = zeros(length(taus),length(t_hors));
policy_all = zeros(length(taus),length(t_hors));

% Tuning
for indexH=1:length(t_hors)
    for indexT=1:length(taus)
        
        % initialize truth, policy, profit counter
        %             thetaStar = theta(:,altTruth(1));
        %             truth = phi(X*thetaStar);
        [a,b,c] = initialize_KG();
        
        % profit over the whole week using truth
        truth_week = 0;
        % profit over the whole week when randomly choosing bid
        rand_week = 0;
        % profit over the whole week when using policy
        policy_week = 0;
        
        % step through a simulation for this tau/t_hor combination
        for i = 1:hrs
            % change truth every 10 hours
            %                 if mod(i,10) == 0
            %                     n = idivide(i,int32(10));
            %                     thetaStar = theta(:,altTruth(n+1));
            %                     truth = phi(X*thetaStar);
            %                 end
            % regular simulation
            [a,b,c,bid] = KG_ms(a,b,c,t_hors(indexH),taus(indexT));
            numAucts = poissrnd(auctions(i));
            if numAucts > A
                numAucts = A;
            end
            bidIndex = find(X(:,2) == bid);
            numClicks = binornd(numAucts,truth(bidIndex));
            % capture profits
            truth_week = truth_week + binornd(numAucts,truth(alt_best))*E_profit(alt_best);
            alt_rand = randi(M);
            rand_week = rand_week + binornd(numAucts,truth(alt_rand))*E_profit(alt_rand);
            policy_week = policy_week + numClicks*E_profit(bidIndex);
            % update policy
            [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
        end
        truth_all(indexT,indexH) = truth_all(indexT,indexH) + truth_week;
        rand_all(indexT,indexH) = rand_all(indexT,indexH) + rand_week;
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
