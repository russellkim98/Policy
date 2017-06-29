% Updates the KG policy after seeing a response from one auction. Takes in 
% an X matrix, a theta matrix, a p vector, the bid placed, and the response
% y seen. Returns the given X and theta matrices as well as an updated p 
% vector p_new.

function [X,theta,p_new] = learner_KG(X,theta,p,bid,y)
x = [1 bid];
p_new = update_p(x,y,theta,p);
end


