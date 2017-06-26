% TESTING SCRIPT !! 

M = 25;  % # of alternatives
K = 25;  % # of possible coefficient vectors 

% alternatives that we are deciding between (discretized bids) 
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% thetas we are deciding between (discretized coefficients)
zero_disc = repmat([-5:-2.5:-15], 1, 5);
one_disc = [ones(1,5) ones(1,5)*2 ones(1,5)*3 ones(1,5)*4 ones(1,5)*5];
theta = [zero_disc ; one_disc];

% prior distribution of p
p_0 = ones(1,K)./K;
p = p_0;

vKG = zeros(M,1);

% Calculate distribution of number of auctions, given the avg # of auctions
% mu in a given time step.
% NOTE: These values are the same for each time step right now, but we
% might want to vary mu later.
mu = 1;
A = mu + 3*sqrt(mu);
probTemp = poisspdf([0:A-1],mu);
probAuct = [probTemp 1-sum(probTemp)];

% Calculate best value without thinking about value of information
fBar = zeros(M,1);
for alt_prime=1:M
    x_prime=X(alt_prime,:);
    for a=1:A
        fBar(alt_prime) = fBar(alt_prime) + probAuct(a)*a*sum(p.*profit(x_prime).*phi(x_prime*theta));
    end
end
best = max(fBar);

% Calculate knowledge gradient for each alternative x
for alt=1:M
    x=X(alt,:);
    val_theta = zeros(1,K);
    for j=1:K
        t=theta(:,j);
        val_auct = zeros(1,A+1);
        % For a = 0, val_auct is already (correctly) 0 
        for a=1:A
            % Only consider the case when y=1 because when y=0, profit=0
            p_next = update_p(x,1,theta,p);
            fBar_next = zeros(M,1);
            for alt_prime=1:M
                x_prime=X(alt_prime,:);
                fBar_next(alt_prime) = sum(p_next.*profit(x_prime));
            end
            val_auct(a+1) = a*max(fBar_next)*phi(x*t);
        end
        val_theta(j) = sum(val_auct.*probAuct);
    end
    vKG(alt) = sum(val_theta.*p) - best;  
end

