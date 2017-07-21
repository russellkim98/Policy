
nTrails=50
nPolicies=3;
N=10;
d=10;
n=200;
temp=rand(n,1)*100;
X=[ones(n,1),rand(n,d)*6-3];
%-------
Xx=X(:,2);
%--------
[M,d]=size(X);
m=zeros(d,1);
lambda=1;
q=ones(d,1)/lambda;
OC=zeros(nTrails,N,nPolicies);
choices=zeros(N,nTrails,nPolicies);
w_est_All=zeros(d,nPolicies);
for trail=1:nTrails
    wStar=normrnd(0,sqrt(lambda),[d,1]);
    truth=sigmoid(X*wStar);
    [a,b]=max(truth);


    samples=zeros(N,M);
    for iii=1:M
        samples(:,iii)=lable_d(wStar,X(iii,:)',N);
    end
    
    count=zeros(M,1);
    w_est=m;
    q_est=q;
    
    for i=1:N   
    %   [indexX,KG]=logKG(X,w_est,q_est);
    % [indexX,sample]=TS(X,w_est,q_est);
    %    KG';
       indexX=VM(X,w_est,q_est);
    %    indexX=i;
       prob=sigmoid(X*w_est);
       x=X(indexX,:)';
       count(indexX)=count(indexX)+1;
       y=samples(count(indexX),indexX);
       w_est=maxW(x,q_est,w_est,y);
       p=sigmoid(sum(w_est.*x));
       q_est=q_est+p.*(1-p).*diag(x*x');
       choices(i,trail,1)=indexX;
       [~,tt]=max(sigmoid(X*w_est));
       OC(trail,i,1)=a-truth(tt);
    end
    w_est_All(:,1)=w_est;
    
   
    count=zeros(M,1);
    w_est=m;
    q_est=q;
    for i=1:N
        
        [indexX,KG]=logKG(X,w_est,q_est);
    % [indexX,sample]=TS(X,w_est,q_est);
    %    KG';
       %indexX=BEM(X,w_est,q_est);
    %    indexX=i;
       prob=sigmoid(X*w_est);
       x=X(indexX,:)';
       count(indexX)=count(indexX)+1;
       y=samples(count(indexX),indexX);
       w_est=maxW(x,q_est,w_est,y);
       p=sigmoid(sum(w_est.*x));
       q_est=q_est+p.*(1-p).*diag(x*x');
       choices(i,trail,3)=indexX;
       [~,tt]=max(sigmoid(X*w_est));
       OC(trail,i,3)=a-truth(tt);
    end
    w_est_All(:,3)=w_est;
    
    count=zeros(M,1);
    w_est=m;
    q_est=q;
    for i=1:N
        
     %  [indexX,KG]=logKG(X,w_est,q_est);
    % [indexX,sample]=TS(X,w_est,q_est);
    %    KG';
       indexX=EPLR(X,w_est,q_est);
    %    indexX=i;
       prob=sigmoid(X*w_est);
       x=X(indexX,:)';
       count(indexX)=count(indexX)+1;
       y=samples(count(indexX),indexX);
       w_est=maxW(x,q_est,w_est,y);
       p=sigmoid(sum(w_est.*x));
       q_est=q_est+p.*(1-p).*diag(x*x');
       choices(i,trail,2)=indexX;
       [~,tt]=max(sigmoid(X*w_est));
       OC(trail,i,2)=a-truth(tt);
    end
    w_est_All(:,2)=w_est;
    
    
    
end
choices;
t=mean(OC);
plot(t(:,:,1))
hold on
plot(t(:,:,2),'r')
plot(t(:,:,3),'g')
legend('Max Variance','KG','EPLR')
hold off

