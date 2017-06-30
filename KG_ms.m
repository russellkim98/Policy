function [X,theta,p,bid,vKG] = KG_ms(X,theta,p,tau)

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
            p_next = update_p_ms(x,tau,y,theta,p);
            [~,val_click(y+1)] = inner_max(X,theta,p_next);
            pClick = nchoosek(tau,y)*phi(x*t)^y*(1-phi(x*t))^(tau-y);
            val_click(y+1) = val_click(y+1) * pClick;
        end
        val_theta(j) = sum(val_click);
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


