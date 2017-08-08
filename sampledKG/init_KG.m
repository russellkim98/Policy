% Initializes knowledge gradient bidding policy. Discretizes bids into
% possible alternatives to test (X), discretizes possible coefficients in
% probability of click function (theta), and creates prior distribution of
% probabilities that each theta vector is a true representation of the
% coefficients of x. 

function [X,theta,p] = init_KG()

% alternatives that we are deciding between
disc = (0:0.5:10)';
X = [ones(length(disc),1) disc];

% thetas we are deciding between
theta = [-2 -3.5 -5 -6.5 -8 -9.5 -2 -3.5 -5 -3 -4.5 -8 -9.5 -11; 1 1 1 1 1 1 0.5 0.5 0.5 1.5 1.5 1.5 1.5 1.5];
K = length(theta);

% prior distribution of p
p_0 = ones(1,K)./K;
p = p_0;

end

