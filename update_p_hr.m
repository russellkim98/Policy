% Updates the p vector after seeing responses for an hour. Takes in an 
% alternative x, a number of auctions, a number of clicks,
% a theta matrix, and a p vector. Returns an updated vector p_new based 
% on the Bayesian updating equations.

function p_new = update_p_hr(x,aucts,clicks,theta,p)

N = aucts - clicks;
p_new = p;

% Update p for all of the clicks that you saw.
for c=1:clicks
    p_new = update_p(x,1,theta,p_new);
end

% Update p for all of the no-click auctions. 
for n=1:N
    p_new = update_p(x,0,theta,p_new);
end

end

