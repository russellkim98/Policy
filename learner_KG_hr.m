% Updates a KG policy after seeing responses over an hour. Takes in 
% an X matrix, a theta matrix, a p vector, the bid placed, the number of
% auctions, and the number of clicks. Returns the given X and theta 
% matrices as well as an updated p vector p_new.

function [X,theta,p_new] = learner_KG_hr(X,theta,p,bid,nAuct,nClick)

x = [1 bid];
N = nAuct - nClick;
p_new = p;

% Update p for all of the clicks that you saw.
for c=1:nClick
    p_new = update_p(x,1,theta,p_new);
end

% Update p for all of the no-click auctions. 
for n=1:N
    p_new = update_p(x,0,theta,p_new);
end

end
