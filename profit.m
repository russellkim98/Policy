% Takes in an alternative vector and a theta vector describing the 
% coeffcients of x. Returns an estimate of the profit.

function p = profit(x,theta)

global year month day day_of_week hour;

fVPC = 1; % Currently, fVPC and d are set to arbitrary constants but
d = 1;    % will be estimated using simulated and/or historical data. 
p = (fVPC + d - x(1,2)).*sigmoid(x*theta);

end

