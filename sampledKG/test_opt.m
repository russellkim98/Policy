% Find and graph the optimal bid and expected profit for each truth. 

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(length(disc),1) disc];
M = length(X);

% thetas we are deciding between
theta = [-1.5 -2.5 -3.5 -4.5 -5.5 -8 -1.5 -2.5 -3.5 -1.5 -2.5 -3.5 -4.5 -5.5; ...
          1 1 1 1 1 1 0.75 0.75 0.75 1.5 1.5 1.5 1.5 1.5];
K = length(theta);

% Find expected profit given a click for each alternative.  
profits = zeros(M,1);
for alt=1:M
    x = X(alt,:);
    profits(alt) = profit(x);
end

% Find optimal bid value and expected profit for an auction for each truth. 
bid_best = zeros(K,1);
F_best = zeros(K,1);
for k=1:K
    thetaStar=theta(:,k);
    F = phi(X*thetaStar);
    F(1) = 0;
    F = F.*profits;
    [maxF,index] = max(F);
    F_best(k) = maxF;
    bid_best(k) = X(index,2);
end

% Graph the truth curves, label the optimal bid value by a '*'
figure;
hold on;
for k=1:K
    t=theta(:,k);
    x = linspace(0,10)';
    X = [ones(length(x),1) x];
    prob = phi(X*t);
    h = plot(x,prob);
    c = get(h,'Color');
    scatter(bid_best(k),phi([1 bid_best(k)]*t),[],c,'*');
end
hold off;

disp(mean(bid_best));

% % Graph the optimal expected profits by their bid values. 
% figure;
% hold on;
% for k=1:K
%     scatter(bid_best(k),F_best(k),[],c,'o','filled');
% end
% hold off;