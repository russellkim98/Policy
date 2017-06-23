% Takes in a matrix X of alternative actions, a matrix theta of possible
% theta vectors, and a matrix prob of probabilities that theta vectors are
% true representations of the coefficients of x. Returns a knowledge
% gradient value for each action. 

function vKG = KG(X,theta,p)
[M,d]=size(X);
[~,K]=size(theta);
vKG=zeros(M,1);

% Calculate best value without thinking about value of information
fBar = zeros(M,1);
for alt=1:M
    x=X(alt,:);
    fBar(alt) = sum(p.*profit(x,theta));
end
best = max(fBar);

% Calculate knowledge gradient for each alternative x
for alt=1:M
    x=X(alt,:);
    % another loop
  
    
    vKG = sum(.*p) - best;
end


