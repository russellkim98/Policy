% Updates the p vector after seeing one response in a given auction.
% Takes in an alternative x, a response y, a theta matrix, and a p vector.
% Returns an updated matrix p_new based on the Bayesian updating equations.

function p_new = update_p(x,y,theta,p)

[~,K] = size(theta);
p_new = zeros(1,K);

% In this case, you're interested in probability of a click.
if y == 1
    for k=1:K
        p_new(k) = phi(x*theta(:,k))*p(k);
    end
    denom = sum(p_new);
    p_new = p_new./denom;
    
% In this case, you're interested in probability of no click.
else
    for k=1:K
        p_new(k) = (1-phi(x*theta(:,k)))*p(k);
    end
    denom = sum(p_new);
    p_new = p_new./denom;
end

end

