function [maxX,Tindex]=VM(X,w_est,q_est)
Tindex=(1-sigmoid(X*w_est)).*sigmoid(X*w_est);
[maxKG, ~]=max(Tindex);
iidex=find(Tindex==maxKG);
maxX=iidex(randi(length(iidex)));
end