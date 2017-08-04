% A module to test logKG/init_logKG/learner_logKG, specifically with
% auctions and clicks coming from distinct locations. Simulates a week on
% a per hour basis. Starts off with a normal prior distribution of the
% coefficients of the logistic function and tries to learn the true curve
% with an online logKG policy. 

global nCountries;
nCountries = 2;

hrs = 168; % Number of steps in each simulation
nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;
numLocations = nCountries + nRegions + nCities; % Number of location indicator variables

% Mean number of auctions per hour of week
global data;
data = csvread('ParsedParam.csv',1,0);
auctions = data_preprocessor();
mu = max(auctions);
A = floor(mu + 3*sqrt(mu));

% Set a reasonable truth
while 1
    % True coefficients for bid, countries, regions, and cities
    wStar = zeros(numLocations+1,1);
    wStar(1) = normrnd(0.75,1);
    for c=1:nCountries
        wStar(1+c) = normrnd(-1,1);
    end
    for r=1:nRegions
        wStar(1+nCountries+r) = normrnd(-2,1);
    end
    for c=1:nCities
        wStar(1+nCountries+nRegions+c) = normrnd(-3,1);
    end
    
    % Initialize policy and set truths for each location
    [X,w_est,q_est] = init_logKG(numLocations+1);
    [M,~] = size(X);
    truth = zeros(nCities,M);
    for city=1:nCities
        [X,~,~] = init_logKG(numLocations+1);
        X = location(X,city);
        truth(city,:) = sigmoid(X*wStar);
    end
    if sum(truth(:,M) < 0.01) == 0
        break;
    end
end

% Find expected profit given a click for each bid.
E_profit = zeros(M,1);
for alt=1:M
    E_profit(alt) = profit(X(alt,1));
end

for h=1:hrs
    % simulate number of auctions for the hour
    numAucts = poissrnd(auctions(h));
    if numAucts > A
        numAucts = A;
    end
    for a=1:numAucts
        % randomly pick a location to set for the auction
        city = ceil(nCities*rand);
        [X,~,~] = init_logKG(numLocations+1);
        X = location(X,city);
        % get bid for that auction
        [x_choice,w_est,q_est] = logKG(X,w_est,q_est,10);
        bid = x_choice(1);
        bidIndex = find(X(:,1) == bid);
        % simulate click or not
        click = binornd(1,truth(city,bidIndex));
        % update estimates of w and q
        [w_est,q_est] = learner_logKG(x_choice,w_est,q_est,1,click);
        
        fprintf('Hr = %d, Bid = %4.1f, Click = %d\n', h, bid, click);
    end
end

% graph to see error
figure;
alt = linspace(0,10)';
for city = 1:nCities
    xX = [alt zeros(length(alt),numLocations)];
    xX = location(xX,city);
    
    trueCurve = sigmoid(xX*wStar);
    estCurve = sigmoid(xX*w_est);
    h = plot(alt,trueCurve);
    hold on;
    plot(alt,estCurve,'--','Color',get(h,'Color'));
    
    [~,alt_best] = max(E_profit.*truth(city,:)');
    opt_bid = X(alt_best,1);
    opt_alt = [opt_bid zeros(1,numLocations)];
    opt_alt = location(opt_alt,city);
    opt_prob = sigmoid(opt_alt*wStar);
    scatter(opt_bid,opt_prob,[],get(h,'Color'),'*');
end


function altMatrix = location(altMatrix,city)

global nCountries;
nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;

country = idivide((city - 1),int32(nCities/nCountries)) + 1;
region = idivide((city - 1),int32(nCities/nRegions)) + 1;
altMatrix(:,1+country) = 1;
altMatrix(:,1+nCountries+region) = 1;
altMatrix(:,1+nCountries+nRegions+city) = 1;

end