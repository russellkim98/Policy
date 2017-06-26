% Takes in a matrix X of alternative actions, a matrix theta of possible
% coeffient vectors, and a matrix p of probabilities that each theta vector
% is a true representation of the coefficients of x. Returns a knowledge
% gradient value for each action, and the given theta and p matrices.

function [vKG,theta,p] = KG(X,theta,p)

[M,~] = size(X);     % # of alternatives and dimensions
[~,K] = size(theta); % # of possible coefficient vectors
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
    fBar(alt_prime) = sum(p.*profit(x_prime));
end
best = max(fBar);

% Calculate best value without thinking about value of information
% val_auct = zeros(1,A+1);
% for a=1:A
%     fBar = zeros(M,1);
%     for alt_prime=1:M
%         x_prime=X(alt_prime,:);
%         fBar(alt_prime) = sum(p.*profit(x_prime));
%     end
%     val_auct(a+1) = a*max(fBar);
% end
% best = sum(val_auct.*probAuct);

% Calculate best value without thinking about value of information
% fBar = zeros(M,1);
% for alt_prime=1:M
%     x_prime=X(alt_prime,:);
%     for a=1:A
%         fBar(alt_prime) = fBar(alt_prime) + probAuct(a)*a*sum(p.*profit(x_prime).*phi(x_prime*theta));
%     end
% end
% best = max(fBar);

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


