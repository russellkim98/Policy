% Tests KG policy functions KG, learner_KG, and initialize_KG.

% alternatives that we are deciding between
M = 25;
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% THE TRUTH
thetaStar=[-7.5;1];
truth = phi(X*thetaStar);
for run=1:5
    [a,b,c] = initialize_KG();
    for i=1:20
        [a,b,c,bid] = KG(a,b,c);
        bidIndex = find(X(:,2) == bid);
        y = binornd(1,truth(bidIndex));
        [a,b,c] = learner_KG(a,b,c,bid,y);
    end
    if run == 1
        plot(1:25,c);
        axis([1 25 0 1]);
        hold on
    else
        plot(c);
    end
end
hold off