% Simply a testing file. IGNORE

N=10;
d=10;
n=200;
X=[ones(n,1),rand(n,d)*6-3];
[M,d]=size(X);

m=zeros(d,1);
w_est=m;
lambda=1;
q=ones(d,1)/lambda;
q_est=q;

[indexX,KG]=logKG(X,w_est,q_est);
[maxKG, hello]=max(KG);
iidex=find(KG==maxKG);
maxX=iidex(randi(length(iidex)));
%disp(iidex);
%disp(hello);
%disp(maxX);

wStar=normrnd(0,sqrt(lambda),[d,1]);

samples=zeros(N,M);
for iii=1:M
    samples(:,iii)=lable_d(wStar,X(iii,:)',N);
end