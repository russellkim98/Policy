% Tests KG policy functions KG, learner_KG, and initialize_KG.

% alternatives that we are deciding between
M = 25;
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% THE TRUTH
mu = 0.8;
A = floor(mu + 3*sqrt(mu));

thetaStar=[-8;1.5];
truth = phi(X*thetaStar);

for run=1:5
    [a,b,c] = initialize_KG();
    for i=1:20
        [a,b,c,bid] = KG_hr(a,b,c);
        bidIndex = find(X(:,2) == bid);
        numAucts = randi(A+1)-1;
        numClicks = binornd(numAucts,truth(bidIndex));
        [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
    end
    if run == 1
        plot(1:10,c);
        axis([1 10 0 1]);
        hold on
    else
        plot(c);
    end
end
hold off