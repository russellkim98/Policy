% Updates the KG policy after seeing responses over an hour. Takes in 
% an X matrix, a theta matrix, a p vector, the bid placed, the number of
% auctions, and the number of clicks. Returns the given X and theta 
% matrices as well as an updated p vector p_new.

function [X,theta,p_new] = learner_KG_hr(X,theta,p,bid,nAuct,nClick)
x = [1 bid];
p_new = update_p_hr(x,nAuct,nClick,theta,p);
end
