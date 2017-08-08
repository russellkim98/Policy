% Updates a logKG policy after seeing responses over an hour. Takes in
% an alternative vector x, a w_est vector, a q_est vector, the number of
% auctions, and the number of clicks. Returns the updated w_est and q_est vectors.

function [w_est,q_est] = learn_logKG(x,w_est,q_est,nAuct,nClick)

N = nAuct - nClick;

% Update w_est and q_est for all of the clicks that you saw.
for c=1:nClick
    w_est=maxW(x,q_est,w_est,1);
    p=sigmoid(sum(w_est.*x));
    q_est=q_est+p.*(1-p).*diag(x*x');
end

% Update w_est and q_est for all of the no-click auctions.
for n=1:N
    w_est=maxW(x,q_est,w_est,-1);
    p=sigmoid(sum(w_est.*x));
    q_est=q_est+p.*(1-p).*diag(x*x');
end

end

