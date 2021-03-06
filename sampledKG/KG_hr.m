% Decides a bid to place considering the next hour as a single period. 
% Takes in a matrix X of alternative actions, a theta matrix, a vector p, 
% and a theta value for the time horizon. Returns the bid that maximizes 
% the knowledge gradient, and the given X, theta, and p matrices.

function bid = KG_hr(X,theta,p,t_hor)

[M,~] = size(X);     % # of alternatives and dimensions
[~,K] = size(theta); % # of possible coefficient vectors

% Calculate distribution of number of auctions, given the avg # of auctions
% mu in a given time step.
% NOTE: These values are the same for each time step right now, but we
% might want to vary mu later.
mu = 0.8;
A = floor(mu + 3*sqrt(mu));
pAuct = poisspdf(0:A-1,mu);
pAuct = [pAuct 1-sum(pAuct)];

% Calculate best value without thinking about value of information
[rewards,F_best] = inner_max(X,theta,p,pAuct);

% Calculate offline knowledge gradient for each alternative x
vKG = zeros(M,1);
for alt=1:M
    x = X(alt,:);
    val_theta = zeros(1,K);
    for j=1:K
        t = theta(:,j);
        val_auct = zeros(1,A+1);
        for a=0:A
            val_click = zeros(1,a+1);
            for c=0:a
                [~,val_click(c+1)] = inner_max(X,theta,update_p_hr(x,a,c,theta,p),pAuct);
                val_click(c+1) = val_click(c+1)*nchoosek(a,c)*phi(x*t)^c*(1-phi(x*t))^(a-c);
            end
            val_auct(a+1) = sum(val_click);
        end
        val_theta(j) = sum(val_auct.*pAuct);
    end
    vKG(alt) = sum(val_theta.*p) - F_best;
end

% Convert offline KG values to online ones.
vOLKG = zeros(size(vKG));
for alt=1:M
    vOLKG(alt) = rewards(alt) + t_hor*vKG(alt);
end

% Choose bid that maximizes KG.
[~,bid] = max(vOLKG);
bid = X(bid,2);

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

% Local function that updates p for a given alternative, a number of
% auctions, and a number of clicks.
function p = update_p_hr(x,nAuct,nClick,theta,p)

N = nAuct - nClick;

% Update p for all of the clicks that you saw.
for c=1:nClick
    p = update_p(x,1,theta,p);
end

% Update p for all of the no-click auctions. 
for n=1:N
    p = update_p(x,0,theta,p);
end

end

