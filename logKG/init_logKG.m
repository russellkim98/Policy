% Initializes a logKG policy. Takes in the number of dimensions d in the
% logistic regression. Discretizes bids into possible alternatives 
% to test (X), and creates a normal prior distribution of the coefficients 
% of x.
%
% Note: Without any attributes, d = 2. This represents a logistic function
% with a constant and one variable representing the bid value. 
% With attributes, d = 1 + number of indicator variables in play. For
% example, if data is coming from 5 distinct cities (all in the same
% region/country), d = 6. 

function [X,w_est,q_est] = init_logKG(d)

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [disc zeros(length(disc),d-1)];

% prior distributions of w_est and q_est
w_est=zeros(d,1);
q_est=ones(d,1)/1;

end

