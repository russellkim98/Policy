% Simple testing module that runs a week-long simulation, keeping track of
% bids, auctions, and clicks.

% historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% Initialize policy and truth
[a,b,c] = initialize_KG();
X = a;
M = length(X);
theta = b;
K = length(theta);
thetaStar = theta(:,randi(K));
truth = phi(X*thetaStar);

% Variables and result matrices
steps = 50;
t_hor = 100;
tau = 1;
aucts = zeros(M,A+1);
clicks = zeros(M,A+1);
bids = zeros(steps,1);

% Simulation
for i = 1:steps
    bid = KG_ms(a,b,c,t_hor,tau);
    bidIndex = find(X(:,2) == bid);
    numAucts = poissrnd(auctions(i));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(bidIndex));
    
    aucts(bidIndex,numAucts+1) = aucts(bidIndex,numAucts+1) + 1;
    clicks(bidIndex,numClicks+1) = clicks(bidIndex,numClicks+1) + 1;
    bids(i) = bid;
    
    c = learner_KG_hr(b,c,bid,numAucts,numClicks);
    disp(i);
end

% Display number of clicks based on bids
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