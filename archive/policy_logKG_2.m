% Uses a knowledge gradient policy with a logistic regression belief model
% to come up with a bid to test using simulated data. Works on the
% synthetic data set generated in the code. 
% Calls MATLAB functions developed by Yingfei Wang. 

clf;

cd logisticKG_yingfei;

N = 100; % time budget (# of simulations/hours)
d = 2;   % # of dimensions
M = 25;  % # of alternatives

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
w_est=w;
q_est=q;

% keep track of number of times KG chooses each alternative
count=zeros(M,1);

for n=1:N
    [indexX,KG]=logKG(X,w_est,q_est); %#ok<ASGLU>
    
    % online extension
    prob = sigmoid(X*w_est);
    OLKG = prob + (N-n)*KG;
    [~,indexX] = max(OLKG); % changes indexX based on online extension
    
    x=X(indexX,:)';
    
    % get response for chosen alternative
    count(indexX)=count(indexX)+1;
    y=samples(count(indexX),indexX);
    
    % update estimates of w and q
    w_est=maxW(x,q_est,w_est,y);
    p=sigmoid(sum(w_est.*x));
    q_est=q_est+p.*(1-p).*diag(x*x');
    
end

% graph to see error
est=sigmoid(X*w_est);
plot(1:M,truth,1:M,est);
axis([-1 M+1 0 1]);

% graph to see how many times each alternative is chosen during run
%figure();
%plot(1:25,count,'o');

cd ..;
