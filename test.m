% Tests KG policy functions KG, learner_KG, and initialize_KG.

% alternatives that we are deciding between
M = 25;
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% THE TRUTH
A = 4;
thetaStar=[-6.5;1];
truth = phi(X*thetaStar);

theta = 100;
[a,b,c] = initialize_KG();
for i=1:100
    [a,b,c,bid] = KG_hr(a,b,c,theta);
    bidIndex = find(X(:,2) == bid);
    numAucts = randi(A+1)-1;
    numClicks = binornd(numAucts,truth(bidIndex));
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
end
plot(1:10,c);

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

%Tune for number of steps to look ahead in mulitstep lookahead
% for tau=1:50
%     [a,b,c] = initialize_KG();
%     [a,b,c,bid,vKG] = KG_ms(a,b,c,tau);
%     if tau == 1
%        scatter(ones(1,M)*tau,vKG);
%        axis([1 50 0 1.5]);
%        hold on
%     else
%        scatter(ones(1,M)*tau,vKG);
%     end
%     %bidIndex = find(X(:,2) == bid);
%     %numAucts = randi(A+1)-1;
%     %numClicks = binornd(numAucts,truth(bidIndex));
%     %[a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
% end