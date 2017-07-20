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
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);
% THE TRUTH
altTruth = 7;
thetaStar=theta(:,altTruth);
truth = phi(X*thetaStar);

% input
taus = [1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
t_hors = [0 50 100 150 200 250 300 350 400 450 500 550 600];
hrs = 168;

% result matrices
profits = zeros(length(taus),length(t_hors));
probs = zeros(length(taus),length(t_hors));

% Tuning
for indexH=1:length(t_hors)
    for indexT=1:length(taus)
        
        [a,b,c] = initialize_KG();
        profit = 0;
        
        for i = 1:hrs
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
        probs(indexT,indexH) = c(altTruth);
        
        indexH
        indexT
    end
end

figure;
surf(t_hors,taus,profits);
title('Profits varying online tunable parameter and time periods to look ahead');
xlabel('Time horizon (online)');
ylabel('Time periods to look ahead');

figure;
surf(t_hors,taus,probs);
title('Probabilities of correct truth');
xlabel('Time horizon (online)');
ylabel('Time periods to look ahead');