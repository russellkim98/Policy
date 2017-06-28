% Takes in a matrix X of alternative actions, a matrix theta of possible
% coeffient vectors, a matrix p of probabilities that each theta vector
% is the true representation, the

%Uses a knowledge gradient policy with a logistic regression belief model
% to come up with bids to test in a Google Ads auction and make a profit.

function [X,theta,p_new] = learner(X,theta,p,x,y)


% update probabilities for possible coefficient vectors
p_new = update_p(x,y,theta,p);

end

