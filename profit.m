% Takes in an alternative vector (a bid) and returns an estimate of the 
% profit.

function y=profit(x)
% fVPC and d are dummy values currently
fVPC = 38; 
d = 3;
y = fVPC + d - x(2);
end

