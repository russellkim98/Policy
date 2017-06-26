% Takes in an alternative x, a response y, a matrix theta of possible
% coeffient vectors, and a matrix p of probabilities that each theta vector
% is the true representation. Returns an updated matrix p_new based on the
% Bayesian updating equations.

function p_new = update_p(x,y,theta,p)

[~,K] = size(theta);
p_new = zeros([size(p)]);

% In this case, you're interested in probability of a click.
if y == 1
    denom = sum(phi(x*theta).*p);
    for k=1:K
        p_new(k) = phi(x*theta(:,k))*p(k)/denom;
    end
    
% In this case, you're interested in probability of no click.
else
    denom = sum((1-phi(x*theta)).*p);
    for k=1:K
        p_new(k) = (1-phi(x*theta(:,k)))*p(k)/denom;
    end
end

end

