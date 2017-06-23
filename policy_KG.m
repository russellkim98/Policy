% Uses a knowledge gradient policy with a logistic regression belief model
% to come up with bids to test in a Google Ads auction and make a profit.

N = 100; % time budget (# of hours)
d = 2;   % # of dimensions
M = 25;  % # of alternatives
K = 25;  % # of possible coefficient vectors 

% alternatives that we are deciding between (discretized bids) 
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% thetas we are deciding between (discretized coefficients)
zero_disc = repmat([-5:-2.5:-15], 1, 5);
one_disc = [ones(1,5) ones(1,5)*2 ones(1,5)*3 ones(1,5)*4 ones(1,5)*5];
theta = [zero_disc ; one_disc];

% prior distribution of p
p_0 = ones(1,K)./K;
p = p_0;

for n=1:N
    
    % chose an alternative (a bid) based on KG policy
    vKG = KG(X,theta,p);
    
    % online application -- maybe just include this in KG
    for alt=1:M
        x=X(alt,:);
        fBar(alt) = sum(p.*profit(x,theta));
    end
    vOLKG = fBar +(N-n).*vKG;
    
    % get a simulated response for chosen alternative
    
    
    % update probabilities for possible coefficient vectors
    
    
    % update time variables
    
end

% graph

