% Compares the knowledge gradient policy with a logistic regression belief
% model with a pure exploitation policy.

% historical data, max number of auctions per hour
oldFolder = cd;
cd ..;
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));
hrs = 168; % # of hours
cd(oldFolder);

% alternatives that we are deciding between
disc = [0:0.25:2,2.5:0.5:10]';
X = [ones(length(disc),1) disc];
[M,d] = size(X);

% prior distributions of w_est and q_est
w=zeros(d,1);
lambda=1;
q=ones(d,1)/lambda;
w_est=w;
q_est=q;

% THE TRUTH
while 1
    wStar_0 = normrnd(-7,sqrt(lambda));
    wStar_1 = normrnd(1,sqrt(lambda));
    wStar=[wStar_0;wStar_1];
    truth=sigmoid(X*wStar);
    if truth(M) > 0.1
        break
    end
end

% Find expected profit given a click for each alternative.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,:));
end
[max_profit,opt_alt] = max(E_profit.*truth);
opt_bid = X(opt_alt,2);

for h=1:hrs
    [bidIndex,KG]=logKG(X,w_est,q_est); % Decide bid based on logKG
    x=X(bidIndex,:)';
    
    % simulate number of auctions, clicks, and profit for the hour
    numAucts = poissrnd(auctions(h));
    if numAucts > A
        numAucts = A;
    end
    numClicks = binornd(numAucts,truth(bidIndex));
    
    % update estimates of w and q
    numNone = numAucts - numClicks;
    for c=1:numClicks
        w_est=maxW(x,q_est,w_est,1);
        p=sigmoid(sum(w_est.*x));
        q_est=q_est+p.*(1-p).*diag(x*x');
    end
    for n=1:numNone
        w_est=maxW(x,q_est,w_est,-1);
        p=sigmoid(sum(w_est.*x));
        q_est=q_est+p.*(1-p).*diag(x*x');
    end
    
end

% graph to see error
x = linspace(0,10)';
xX = [ones(length(x),1) x];
trueCurve = sigmoid(xX*wStar);
estCurve = sigmoid(xX*w_est);
h = plot(x,trueCurve);
hold on;
plot(x,estCurve);
hello = sigmoid(opt_alt*wStar);
scatter(opt_bid,sigmoid([1 opt_bid]*wStar),[],get(h,'Color'),'*');


