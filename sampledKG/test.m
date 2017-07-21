% Tests KG policy functions KG, learner_KG, and initialize_KG.

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

% thetas we are deciding between
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);

% thetaStar=theta(:,1);
% truth = phi(X*thetaStar);

% steps = 10;
% aucts = zeros(M,A+1);
% clicks = zeros(M,A+1);
% bids = zeros(steps,1);
% 
% [a,b,c] = initialize_KG();
% tau = 15;
% 
% for i=1:steps
% 
%     [a,b,c,bid,KG,reward] = KG_ms(a,b,c,tau);
%     bidIndex = find(X(:,2) == bid);
%     numAucts = poissrnd(auctions(i));
%     if numAucts > A
%         numAucts = A;
%     end
%     numClicks = binornd(numAucts,truth(bidIndex));
% 
%     aucts(bidIndex,numAucts+1) = aucts(bidIndex,numAucts+1) + 1;
%     clicks(bidIndex,numClicks+1) = clicks(bidIndex,numClicks+1) + 1;
%     bids(i) = bid;
% 
%     plot(1:M,KG);
%     hold on;
%     plot(reward);
%     hold off;
% 
%     cd graphs;
%     saveas(gcf,sprintf('hour%d.png',i));
%     cd ..;
% 
%     [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
%     disp(i);
% 
% end
% 
% init_c = c;
% 
% % Tune for number of steps to look ahead in mulitstep lookahead
% for tau=1:50
%     ax = gca;
%     ax.ColorOrderIndex = 1;
%     c = init_c;
%     [a,b,c,bid,KG,~] = KG_ms(a,b,c,tau);
%     if tau == 1
%         figure;
%         axis([1 50 0 1]);
%         hold on
%         for alt=1:M
%             scatter(tau,KG(alt));
%         end
%     else
%         for alt=1:M
%             scatter(tau,KG(alt));
%         end
%     end
%     disp(tau);
% end

% theta = 100;
% [a,b,c] = initialize_KG();
% for i=1:100
%     [a,b,c,bid] = KG_hr(a,b,c,theta);
%     bidIndex = find(X(:,2) == bid);
%     numAucts = randi(A+1)-1;
%     numClicks = binornd(numAucts,truth(bidIndex));
%     [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
% end
% plot(1:10,c);

% See differences between multistep and single period lookahead
% for run=1:5
%
%     ax = gca;
%     ax.ColorOrderIndex = 1;
%
%     [a,b,c] = initialize_KG();
%     for i=1:50
%         [a,b,c,bid] = KG(a,b,c);
%         bidIndex = find(X(:,2) == bid);
%         y = binornd(1,truth(bidIndex));
%         [a,b,c] = learner_KG(a,b,c,bid,y);
%     end
%     if run == 1
%         plot(1:10,c);
%         axis([1 10 0 1]);
%         hold on;
%     else
%         plot(1:10,c);
%     end
%
%     [d,e,f] = initialize_KG();
%     for i=1:50
%         [d,e,f,bid] = KG_ms(d,e,f,25);
%         bidIndex = find(X(:,2) == bid);
%         y = binornd(1,truth(bidIndex));
%         [d,e,f] = learner_KG(d,e,f,bid,y);
%     end
%     plot(f);
%
% end