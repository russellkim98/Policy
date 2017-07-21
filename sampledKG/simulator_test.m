% historical data
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(length(disc),1) disc];
M = length(X);

% the truth
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);
thetaStar=theta(:,8);
truth = phi(X*thetaStar);

% time horizons to test
% vals = [0.01 0.055 0.1 0.55 1 5.5 10 55 100 550 1000];
% t_max = length(vals);
% profits = zeros(1,t_max);
% probs = zeros(10,t_max);

steps = 168;

% for t_hor=1:t_max

aucts = zeros(M,A+1);
clicks = zeros(M,A+1);
bids = zeros(steps,1);
OC = zeros(steps,1);

[a,b,c] = initialize_KG();

for i = 1:steps
    profit = 0;
    [a,b,c,bid,KG,reward] = KG_ms(a,b,c);
    bidIndex = find(X(:,2) == bid);
    numAucts = poissrnd(auctions(i));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(bidIndex));
    
    aucts(bidIndex,numAucts+1) = aucts(bidIndex,numAucts+1) + 1;
    clicks(bidIndex,numClicks+1) = clicks(bidIndex,numClicks+1) + 1;
    bids(i) = bid;
    profit = profit + numClicks*(20 - bid);  
    
    plot(1:M,KG);
    hold on;
    plot(reward);
    hold off;
    
    cd graphs;
    saveas(gcf,sprintf('hour%d.png',i));
    cd ..;
    
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
    disp(i);
end


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

%     profits(t_hor) = profit;
%     for i = 1:length(c)
%         probs(i,t_hor) = c(i);
%     end
%     disp(vals(t_hor));
%     disp(profits);
%     disp(probs);

% end