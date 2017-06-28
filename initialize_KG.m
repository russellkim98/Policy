% Initializes knowledge gradient bidding policy. Discretizes bids into
% possible alternatives to test (X), discretizes possible coefficients in
% probability of click function (theta), and creates prior distribution of
% probabilities that each theta vector is a true representation of the
% coefficients of x. 

function [X,theta,p] = initialize_KG( input_args )

d = 2;   % # of dimensions
M = 25;  % # of alternatives
K = 25;  % # of possible coefficient vectors

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% thetas we are deciding between
zero_disc = repmat([-5:-2.5:-15], 1, 5);
one_disc = [ones(1,5) ones(1,5)*2 ones(1,5)*3 ones(1,5)*4 ones(1,5)*5];
theta = [zero_disc ; one_disc];

% prior distribution of p
p_0 = ones(1,K)./K;
p = p_0;

end

