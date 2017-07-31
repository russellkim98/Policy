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
theta = [-1.5 -2.5 -1.5 -2.5     -5 -6.5 -8 -9.5 -11 -2     -9 -10 -4.5 -5.5; ...
          1 1 1.5 1.5     1 1 1.5 1.5 1.5 0.5     1 1 0.5 0.5];
theta_grp = [1 1 1 1 2 2 2 2 2 2 3 3 3 3];
K = length(theta);

% input
taus = [1 5 10 15 20 25 30];
t_hors = [0 10 100 1000];
hrs = 168;

% result matrix
profits = zeros(length(taus),length(t_hors));

% Tuning
for indexH=1:length(t_hors)
    for indexT=1:length(taus)
        
        % THE TRUTH
        altTruth = ceil(rand*K);
        thetaStar = theta(:,altTruth);
        truth = phi(X*thetaStar);
        % initialize
        [a,b,c] = initialize_KG();
        profit = 0;
        
        for i = 1:hrs
            % change truth every 10 hours
            if mod(i,10) == 0
                altNewTruth = ceil(rand*K);
                while theta_grp(altNewTruth) == theta_grp(altTruth)
                    altNewTruth = ceil(rand*K);
                end
                altTruth = altNewTruth;
                thetaStar = theta(:,altTruth);
                truth = phi(X*thetaStar);
            end
            % regular simulation
            [a,b,c,bid] = KG_ms(a,b,c,t_hors(indexH),taus(indexT));
            numAucts = poissrnd(auctions(i));
            if numAucts > A
                numAucts = A;
            end
            bidIndex = find(X(:,2) == bid);
            numClicks = binornd(numAucts,truth(bidIndex));
            profit = profit + numClicks*(20 - bid);
            [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
        end
        
        profits(indexT,indexH) = profit;
        
        indexH
        indexT
    end
end

figure;
surf(t_hors,taus,profits);
title('Profits varying online tunable parameter and time periods to look ahead');
xlabel('Time horizon (online)');
ylabel('Time periods to look ahead');