% The simplest module to test KG_ms/init_KG/learn_KG. 
%
% Starts off believing each possible theta vector is equally likely to be
% the true vector and tries to learn the true curve with an online logKG
% policy. Runs a simulation hour-by-hour and displays the number of clicks
% varying the bid value at each time step. The larger the data point on
% this graph, the more often we saw that number of clicks resulting from
% that bid. 

t_hor = 100;     % value of time horizon tunable parameter
tau = 1;         % value of lookahead tunable parameter
steps = 50;      % # of hours in simulation

% average # of auctions for each hour of the week based on historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();

% establish max number of auctions for plotting purposes 
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% initialize policy and truth
[a,b,c] = init_KG();
M = length(a);
K = length(b);
thetaStar = b(:,randi(K));
truth = phi(X*thetaStar);

% result matrices
clicks = zeros(M,A+1);

for i = 1:steps
    bid = KG_ms(a,b,c,t_hor,tau);
    bidIndex = find(X(:,2) == bid);
    numAucts = poissrnd(auctions(i));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(bidIndex));
    % keeps track of how many clicks there were for that bid
    clicks(bidIndex,numClicks+1) = clicks(bidIndex,numClicks+1) + 1;
    [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
    disp(i);
end

% display number of clicks based on bids
figure;
axis([1 M 0 A]);
hold on;
for a=1:A+1
    for m=1:M
        if clicks(m,a) ~= 0
            scatter(m,a-1,clicks(m,a)*10,'green');
        end
    end
end
hold off;