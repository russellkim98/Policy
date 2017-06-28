% Takes in a matrix X of alternative actions, a matrix theta of possible
% coeffient vectors, and a matrix p of probabilities that each theta vector
% is the true representation. Returns the bid that maximizes the knowledge 
% gradient, and the given X, theta, and p matrices.

function [X,theta,p,bid] = KG(X,theta,p)

[M,~] = size(X);     % # of alternatives and dimensions
[~,K] = size(theta); % # of possible coefficient vectors

% Calculate distribution of number of auctions, given the avg # of auctions
% mu in a given time step.
% NOTE: These values are the same for each time step right now, but we
% might want to vary mu later.
mu = 1;
A = mu + 3*sqrt(mu);
pTemp = poisspdf(0:A-1,mu);
pAuct = [pTemp 1-sum(pTemp)];

% Calculate best value without thinking about value of information
[rewards,x_best] = inner_max(X,theta,p,pAuct);

% Calculate offline knowledge gradient for each alternative x
vKG = zeros(M,1);
for alt=1:M
    x = X(alt,:);
    val_theta = zeros(1,K);
    for j=1:K
        t = theta(:,j);
        val_resp = zeros(1,2);
        for y=0:1
            p_next = update_p(x,y,theta,p);
            [~,val_resp(y+1)] = inner_max(X,theta,p_next,pAuct);
        end
        val_theta(j) = val_resp(1)*(1-phi(x*t))+val_resp(2)*phi(x*t);
    end
    vKG(alt) = sum(val_theta.*p) - x_best;
end

% Convert offline KG values to online ones.
vOLKG = zeros(size(vKG));
for alt=1:M
    vOLKG(alt) = vKG(alt) + rewards(alt);
end

% Choose bid that maximizes KG.
[~,indexMax] = max(vKG);
bid = X(indexMax,2);

end

% Local function that takes in a matrix a matrix X of alternative actions, 
% a matrix theta of possible coeffient vectors, a matrix p of probabilities
% that each theta vector is the true representation, and a matrix pAuct
% of probabilities that a given number of auctions take place. Returns the
% expected reward for each alternative and the best of those values. 
function [val_x,best] = inner_max(X,theta,prob,pAuct)

[M,~] = size(X);
[~,K] = size(theta);
[~,A] = size(pAuct);
A = A - 1;

val_x = zeros(1,M);
for alt=1:M
    x = X(alt,:);
    val_theta = zeros(1,K);
    for k=1:K
        t = theta(:,k);
        val_auct = zeros(1,A+1);
        % For a = 0, val_auct is already (correctly) 0
        for a=1:A
            % Only consider the case when y=1 because when y=0, profit=0
            val_auct(a+1) = a*profit(x)*phi(x*t);
        end
        val_theta(k) = sum(val_auct.*pAuct);
    end
    val_x(alt) = sum(val_theta.*prob);
end

best = max(val_x);

end

