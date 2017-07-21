% Modified version of Yingfei Wang's logKG code.
%
% Uses an online knowledge gradient policy with a logistic regression
% belief model to come up with a bid to place in the next auction. Takes in
% a matrix X of alternative actions (discretized bids), matrices w_est
% and q_est representing the distribution of the estimated coefficients of
% the logistic function, and a time horizon tunable parameter for the
% online application. Returns the given X, w_est, and q_est matrices as
% well as the chosen bid. 

function [X,w_est,q_est,bid]=logKG(X,w_est,q_est,t_hor)

[M,~] = size(X);
KG = zeros(M,1);

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,:));
end

for i=1:M % for each alternative, calculate the KG value
    x=X(i,:)';
    mu=X(i,:)*w_est;
    sigma_squared=sum(1./q_est.*x.*x);
    
    % for y=+1
    w_1=maxW(x,q_est,w_est,1);
    p=sigmoid(w_1.*x);
    q_1=q_est+p.*(1-p).*diag(x*x');
    q_rep=repmat(1./q_1',[M,1]);
    sigma_x_squared_1= sum(q_rep.*X.*X,2);
    mu_1=X*w_1;
    
    %for y=-1
    w_0=maxW(x,q_est,w_est,-1);
    p=sigmoid(w_0.*x);
    q_0=q_est+p.*(1-p).*diag(x*x');
    q_rep=repmat(1./q_0',[M,1]);
    sigma_x_squared_0= sum(q_rep.*X.*X,2);
    mu_0=X*w_0;
    
    KG(i)=sigmoid(kappa(sigma_squared)*mu)*max(E_profit.*sigmoid(kappa(sigma_x_squared_1).*mu_1))...
        +(1-sigmoid(kappa(sigma_squared)*mu))*max(E_profit.*sigmoid(kappa(sigma_x_squared_0).*mu_0));
end

% online extension
OLKG = E_profit.*sigmoid(X*w_est) + t_hor*KG;
[~,bidIndex] = max(OLKG);
bid = X(bidIndex,2);

end