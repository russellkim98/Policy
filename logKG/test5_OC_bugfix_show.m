% Compares randomness controlled OC computation vs. not controlled OC comp.
% based on test5.m
% Donghun Lee

% below comment is from test5.m 
% A module to test the behavior of logKG/init_logKG/learner_logKG, 
% specifically with a changing truth. Graphs the opportunity cost of the 
% policy as a function of the number of steps in the simulation. 
%
% Starts off with normal prior distributions of the coefficients of the 
% logistic function and tries to learn the true curves with an online logKG 
% policy with a tunable parameter value of 10. Simulates a week on a per 
% hour basis. Graphs the true and estimated curves.

OC_avg_1 = test5_fn(true);
OC_avg_0 = test5_fn(false);

OC_avg = horzcat(OC_avg_1, OC_avg_0);
OC_avg_legend = {'rand-controlled OC', 'rand-uncontrolled OC'};

% % graph average opportunity cost for each hour
figure('Units', 'inches', 'Position', [1, 1, 8, 6], 'PaperPositionMode', 'Auto');
hold on;
plot(1:hrs,OC_avg);
% 
% for i=1:length(iChanges)
%     scatter(iChanges(i),OC_avg(iChanges(i)),'blue')
% end
title('OC using logKG (param. tuned)');
xlabel('Time (simulated) (in hours)');
ylabel('Sample averaged OC (20 runs)');
legend(OC_avg_legend)
print -dpdf test5_OC_bugfix_show.pdf
print -depsc2 test5_OC_bugfix_show.eps

% ------------- begin function definitions ------------

function OC_avg = test5_fn(rand_control_in_test5)

% init randomness controlling
seed = 12345;
rng(seed)

t_hor = 10;        % value of time horizon tunable parameter
hrs = 4*168;        % # of hours in simulation
runs = 20;         % # of simulations 
% probChange = 0.05; % probability of changing truth for a given step

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% initialize policy
[X,~,~] = init_logKG(2);
X(:,2) = 1;
[M,~] = size(X);
OC_all = zeros(hrs,1);

% Find expected profit given a click for each bid.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit2(X(alt,1));
end

for r=1:runs
    
    % randomly set a reasonable truth
    while 1
        wStar_0 = normrnd(-7,1); % coefficient for constant
        wStar_1 = normrnd(1,1);  % coefficient for bid value
        wStar = [wStar_1;wStar_0];
        truth = sigmoid(X*wStar);
        [~,alt_best] = max(E_profit.*truth);
        if truth(M) > 0.1
            break
        end
    end
    
    % prior distributions of w_est and q_est
    [X,w_est,q_est] = init_logKG(2);
    X(:,2) = 1;
    
    for h=1:hrs
        % cancelled this: occasionally change to another randomized, reasonable truth
        if h == 1  % mod(h,100) == 0
            while 1
                wStar_0 = normrnd(-7,1); % coefficient for constant
                wStar_1 = normrnd(1,1);  % coefficient for bid value
                wStar=[wStar_1;wStar_0];
                truth=sigmoid(X*wStar);
                [~,alt_best] = max(E_profit.*truth);
                if truth(M) > 0.1
                    break
                end
            end
        end
        % get bid
        x_choice = logKG(X,w_est,q_est,t_hor);
        bid = x_choice(1);
        bidIndex = find(X(:,1) == bid);
        % simulate number of auctions, clicks, and OC for the hour
        hour_of_week = mod(h-1,168) + 1;
        numAucts = poissrnd(auctions(hour_of_week));
        
        if rand_control_in_test5 == true
            s = rng;  % capture rng state
        end
        numClicks = binornd(numAucts,truth(bidIndex));
        if rand_control_in_test5 == true
            rng(s);   % revert rng state
        end
        best_case_numClicks = binornd(numAucts, truth(alt_best));
        this_OC = best_case_numClicks*E_profit(alt_best) - numClicks*E_profit(bidIndex);
        OC_all(h) = OC_all(h) + this_OC;
        % update estimates of w and q
        [w_est,q_est] = learn_logKG(x_choice,w_est,q_est,numAucts,numClicks);
    end
    
    r
    
end

OC_avg = OC_all/runs;

end