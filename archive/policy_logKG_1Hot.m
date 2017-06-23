% Combining 1-Hot with logKG in this way does not work as is.
% This code was just used to test something out but might have potential 
% later.

% Uses a knowledge gradient policy with a logistic regression belief model
% to come up with an hour of the week to test using simulated data. 
% Calls MATLAB functions developed by Yingfei Wang from her logistic KG work.

% Read in simulated data. Right now, this is just a modified copy of
% ParsedParam only with hour_of_week, auctions, clicks, cost, and value per
% conversion.

data = importdata('SimulatorOutput.csv');
numHOW = 168;

colHOW = 1;
colClick = 3;

cd logisticKG_yingfei;

% set up
N = 400; % cannot be more than 416 if you're using actual data
M = numHOW;
d = numHOW+1;

% alternatives that we are deciding between
alt = diag(ones(M,1));
X = [ones(M,1) alt];

% Samples to learn with, taken from actual data!
samples = zeros(N,M);
click = logical(data(:,colClick));
click(click==0) = -1;
for k = 1:M
    clickK = click(data(:,colHOW) == k);
    samples(:,k) = datasample(clickK,N,'Replace',false);
end

% prior distributions of w_est and q_est
w = zeros(d,1);
lambda = 1;
q = ones(d,1)/lambda;

count=zeros(M,1);
w_est=w;
q_est=q;

for n=1:N
    [indexX,KG]=logKG(X,w_est,q_est);
    x=X(indexX,:)';
    count(indexX)=count(indexX)+1;
    y=samples(count(indexX),indexX);
    w_est=maxW(x,q_est,w_est,y);
    p=sigmoid(sum(w_est.*x));
    q_est=q_est+p.*(1-p).*diag(x*x');
% Testing code
%     if i==1
%         est=sigmoid(X*w_est);
%         plot(1:M,est);
%         axis([1 M 0 1]);
%         hold on;
%     end
%     if i==100|i==200|i==300|i==400
%         est=sigmoid(X*w_est);
%         plot(1:M,est);
%     end
end

% Probably don't come up with w_est and q_est this way
% Logical array specifying whether a click was made. This binary outcome
% allows us to use Yingfei's algorithm and code.
% click = logical(data(:,colClick));
%theta_est = zeros(numHOW, 1);
%for k = 1:numHOW
%    clickK = click(data(:,colHOW) == k);
%    avgClickK = sum(clickK)/length(clickK);
%    theta_est(k) = log(1/avgClickK - 1);
%end
%q_est=ones(numHOW,1);

cd ..;
