% Uses a knowledge gradient policy with a logistic regression belief model
% to come up with a bid to test using simulated data. 
% Calls MATLAB functions developed by Yingfei Wang. 

cd logisticKG_yingfei;

N = 1000; % time budget (# of simulations)
d = 2;    % # of dimensions
M = 25;   % # of alternatives

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(M,1) disc];

% THE TRUTH 
wStar=[-10;1];
truth=sigmoid(X*wStar);
[a,b]=max(truth);

% Samples to learn with
samples=zeros(N,M);
for iii=1:M
    samples(:,iii)=lable_d(wStar,X(iii,:)',N);
end

% prior distributions of w_est and q_est
w=zeros(d,1);
lambda=1;
q=ones(d,1)/lambda;

count=zeros(M,1);
w_est=w;
q_est=q;

for i=1:N
    [indexX,KG]=logKG(X,w_est,q_est);
    x=X(indexX,:)';
    count(indexX)=count(indexX)+1;
    y=samples(count(indexX),indexX);
    w_est=maxW(x,q_est,w_est,y);
    p=sigmoid(sum(w_est.*x));
    q_est=q_est+p.*(1-p).*diag(x*x');
end

disp(w_est);
cd ..;
