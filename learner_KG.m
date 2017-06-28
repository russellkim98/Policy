% Takes in a matrix X of alternative actions, a matrix theta of possible
% coeffient vectors, a matrix p of probabilities that each theta vector
% is the true representation, the action x taken and the response y seen.
% Returns the given X and theta matrices as well as an updated p vector
% p_new.

function [X,theta,p_new] = learner_KG(X,theta,p,bid,y)
x = [1 bid];
p_new = update_p(x,y,theta,p);
end


