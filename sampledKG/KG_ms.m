% Decides a bid to place looking ahead tau auctions. Takes in a matrix X of
% alternative actions, a theta matrix, a vector p, a tau value, and a theta
% value for the time horizon. Returns the bid that maximizes the knowledge
% gradient, and the given X, theta, and p matrices.

function [X,theta,p,bid] = KG_ms(X,theta,p,t_hor,tau)

[M,~] = size(X);     % # of alternatives and dimensions
[~,K] = size(theta); % # of possible coefficient vectors

% Calculate best value without thinking about value of information
[rewards,F_best] = inner_max(X,theta,p);

% Calculate offline knowledge gradient for each alternative x
vKG = zeros(M,1);
for alt=1:M
    x = X(alt,:);
    val_theta = zeros(1,K);
    for j=1:K
        t = theta(:,j);
        val_click = zeros(1,tau+1);
        for y=0:tau
            [~,val_click(y+1)] = inner_max(X,theta,update_p_ms(x,tau,y,theta,p));
            val_click(y+1) = val_click(y+1)*nchoosek(tau,y)*phi(x*t)^y*(1-phi(x*t))^(tau-y);
        end
        val_theta(j) = sum(val_click);
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

% Local function that returns the expected reward for each alternative and
% the best of those values.
function [val_x,best] = inner_max(X,theta,p)

[M,~] = size(X);
[~,K] = size(theta);

val_x = zeros(1,M);
for alt=1:M
    x = X(alt,:);
    val_theta = zeros(1,K);
    for k=1:K
        t = theta(:,k);
        % Only consider the case when y=1 because when y=0, profit=0
        val_theta(k) = profit(x)*phi(x*t);
    end
    val_x(alt) = sum(val_theta.*p);
end

best = max(val_x);

end

% Local function that updates p for a given alternative, a number of
% auctions, and a number of clicks.
function p_new = update_p_ms(x,nA,nC,theta,p)

[~,K] = size(theta);
p_new = zeros(1,K);

for k=1:K
    t = theta(:,k);
    p_new(k) = nchoosek(nA,nC)*phi(x*t)^nC*(1-phi(x*t))^(nA-nC)*p(k);
end
denom = sum(p_new);
p_new = p_new./denom;

end


