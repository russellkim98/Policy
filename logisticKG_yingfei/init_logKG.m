% Initializes a logKG policy. Discretizes bids into possible alternatives 
% to test (X), and creates a normal prior distribution of the coefficients 
% of x.

function [X,w_est,q_est] = init_logKG()

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(length(disc),1) disc];
[~,d] = size(X);

% prior distributions of w_est and q_est
w_est=zeros(d,1);
q_est=ones(d,1)/lambda;

end

