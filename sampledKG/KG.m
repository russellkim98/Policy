% Decides a bid to place for the next auction. Takes in a matrix X of
% alternative actions, a theta matrix, and a p vector. Returns the bid that
% maximizes the knowledge gradient, and the given X, theta, and p matrices.

function [X,theta,p,bid] = KG(X,theta,p)

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
        val_resp = zeros(1,2);
        for y=0:1
            p_next = update_p(x,y,theta,p);
            [~,val_resp(y+1)] = inner_max(X,theta,p_next);
        end
        val_theta(j) = val_resp(1)*(1-phi(x*t))+val_resp(2)*phi(x*t);
    end
    vKG(alt) = sum(val_theta.*p) - F_best;
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

