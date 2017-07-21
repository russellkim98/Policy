% Compares the knowledge gradient policy with a logistic regression belief
% model with a pure exploitation policy.

runs = 25;

% historical data, max number of auctions per hour
oldFolder = cd;
cd ..;
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));
hrs = 168;
cd(oldFolder);

% Initialize policy
[X,w_est,q_est] = init_logKG();
[M,d] = size(X);

t_hors = 0:1:50;
OC_all = zeros(length(t_hors),1);

for r=1:runs
    % THE TRUTH
    while 1
        wStar_0 = normrnd(-7,1);
        wStar_1 = normrnd(1,1);
        wStar=[wStar_0;wStar_1];
        truth=sigmoid(X*wStar);
        if truth(M) > 0.1
            break
        end
    end
    
    % Find expected profit given a click for each alternative.
    E_profit = zeros(M,1);
    for alt=1:M
        E_profit(alt) = profit(X(alt,:));
    end
    [~,alt_best] = max(E_profit.*truth);
    
    for t=1:length(t_hors)
        
        % prior distributions of w_est and q_est
        [X,w_est,q_est] = init_logKG();
        OC = 0;
        
        for h=1:hrs
            [X,w_est,q_est,bid]=logKG(X,w_est,q_est);
            
            % simulate number of auctions, clicks, and profit for the hour
            numAucts = poissrnd(auctions(h));
            if numAucts > A
                numAucts = A;
            end
            numClicks = binornd(numAucts,truth(bidIndex));
            OC = OC + binornd(numAucts,truth(alt_best))*E_profit(alt_best) - numClicks*E_profit(bidIndex);
            
            % update estimates of w and q
            [X,w_est,q_est] = learner_logKG(X,w_est,q_est,bid,numAucts,numClicks);
        end
        OC_all(t) = OC_all(t) + OC;
    end
    r
end

% Graph profits
figure;
OC_avg = OC_all/runs;
plot(t_hors,OC_avg);
title('Average weekly OC varying time horizon tunable parameter for logKG');
xlabel('Value of tunable parameter');
ylabel('OC over the week, averaged over 25 runs (in dollars)');

% graph to see error
% figure;
% x = linspace(0,10)';
% xX = [ones(length(x),1) x];
% trueCurve = sigmoid(xX*wStar);
% estCurve = sigmoid(xX*w_est);
% h = plot(x,trueCurve);
% hold on;
% plot(x,estCurve);
% opt_bid = X(alt_best,2);
% scatter(opt_bid,sigmoid([1 opt_bid]*wStar),[],get(h,'Color'),'*');


