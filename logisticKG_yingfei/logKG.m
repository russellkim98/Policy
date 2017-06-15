function [maxX,KG]=logKG(X,w_est,q_est)
[M,d]=size(X);
KG=zeros(M,1);

mu_all=X*w_est;
q_rep=repmat(1./q_est',[M,1]);
sigma_x_squared=sum(q_rep.*X.*X,2);
for i=1:M % for each alternative, calculate the KG value
   x=X(i,:)';
   mu=X(i,:)*w_est;
   sigma_squared=sum(1./q_est.*x.*x);
   
   % for y=+1
   w_1=maxW(x,q_est,w_est,1);
   p=sigmoid(w_1.*x);
   q_1=q_est+p.*(1-p).*diag(x*x');
   q_rep=repmat(1./q_1',[M,1]);
   sigma_x_squared_1= sum(q_rep.*X.*X,2);
   mu_1=X*w_1;
   
   %for y=-1
   w_0=maxW(x,q_est,w_est,-1);
   p=sigmoid(w_0.*x);
   q_0=q_est+p.*(1-p).*diag(x*x');
   q_rep=repmat(1./q_0',[M,1]);
   sigma_x_squared_0= sum(q_rep.*X.*X,2);
   mu_0=X*w_0;
% 
   KG(i)=sigmoid(kappa(sigma_squared)*mu)*max(sigmoid(kappa(sigma_x_squared_1).*mu_1))...
        +(1-sigmoid(kappa(sigma_squared)*mu))*max(sigmoid(kappa(sigma_x_squared_0).*mu_0));
%              -max(sigmoid(kappa(sigma_x_squared).*mu_all));

%      KG(i)=sigmoid(kappa(sigma_squared)*mu)*max(mu_1)...
%           +(1-sigmoid(kappa(sigma_squared)*mu))*max(mu_0)...
%           -max(mu_all);
% 
%    KG(i)=max(max(sigmoid(kappa(sigma_x_squared_1).*mu_1)),max(sigmoid(kappa(sigma_x_squared_0).*mu_0)))...
%            -max(sigmoid(kappa(sigma_x_squared).*mu_all));
%      
end
[maxKG, ~]=max(KG);
iidex=find(KG==maxKG);
maxX=iidex(randi(length(iidex)));

end

function k=kappa(sigma_squared)
k=1./sqrt(1+pi*sigma_squared/8);
end