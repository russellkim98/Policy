# README #

### What is this repository for? ###

* Files for running various policies to decide bid values for auctions on Google Ads
* Click [here](https://www.overleaf.com/10139484dwhqqgbkvfrc#/37428144/) to see mathematical models/write-ups of some of these policies.

### Requirements ###
 
* MATLAB

### Folders ###

* logKG -- Contains all of the functions and testing modules for the KG policy adapted from Yingfei Wang's work, including init_logKG, logKG, and learner_logKG. 
* sampledKG -- Contains all of the functions and testing modules for the KG policies using a sampled belief model, including initialize_KG, KG_hr, KG_ms, and learner_KG_hr.

### Instructions ###

#### KG Policies (Sampled Belief Model) ####

1. Call **init_KG** once at the start of a run of simulations to initialize a policy. It takes in no parameters and returns 3 matrices that should be stored and passed on in the first call to KG_hr or KG_ms. 

2. Call **KG_hr** or **KG_ms** during each simulated hour to choose a bid. Each takes in the 3 matrices that were previously stored and a tunable parameter t_hor representing the time horizon. **KG_ms** takes in an additional tunable parameter tau representing the number of auctions to look ahead. Both functions return only a bid value. 
    * When t_hor is large, the policy places an emphasis on the value of learning and the profit you can make after learning; when t_hor is small, the policy places an emphasis the the profit you make while learning.
    * When tau is too large, the policy will look ahead too many auctions with diminishing marginal returns. When tau is too small, the policy isn't looking ahead enough auctions to fully make use of looking ahead. 

3. Simulate the number of auctions and the number of clicks during each simulated hour.

4. Call **learn_KG** during each simulated hour to update the policy. **learn_KG** takes in the bid, the second 2 matrices that were previously stored, the number of auctions and the number of clicks for the hour. It returns updated versions of the 2 matrices to be stored and passed on in the next call to KG_hr or KG_ms. 

5. At the end of a run of simulations, the 2 matrices put out by **learn_KG** give you the possible truths and their probabilities of being true, respectively.


#### logKG Policies (Parametric Belief Model) ####

1. Call **init_logKG** once at the start of a run of simulations to initialize a policy. It takes in an integer value representing the dimension of the problem and returns 3 matrices that should be stored and passed on in the first call to logKG. 
    * Without any attributes, the dimension of the problem for **init_logKG** is 2 (representing a logistic function with one variable representing the bid value and a constant).
    * With attributes, the dimension is equal to 1 + the number of indicator variables in play. For example, if data is coming from 5 distinct cities (all in the same region/country), d = 6. Additionally, with attributes, the first matrix that is returned from **init_logKG** is modified before being passed on logKG.

2. Call **logKG** during each simulated hour to choose a bid. It takes in 3 matrices that were previously stored and a tunable parameter t_hor representing the time horizon. When t_hor is large, the policy places an emphasis on the value of learning and the profit you can make after learning; when t_hor is small, the policy places an emphasis the the profit you make while learning. It returns a vector representing the chosen alternative, to be stored and passed on exactly in the next call to learn_logKG. The first value of the vector returned by **logKG** is the bid value. 
    * Without any attributes, **logKG** takes in the exact 3 matrices that were previously stored.
    * With attributes, the first matrix that was previously stored is modified to turn "on" the indicator variables that represent the correct attributes. That is, before each call to **logKG**, the attributes are decided. Only the indicator variable(s) corresponding with those attributes are turned on in the first matrix. The other two matrices that were previously stored are passed on exactly to **logKG**.

3. Simulate the number of auctions and the number of clicks during each simulated hour.

4. Call **learn_logKG** during each simulated hour to update the policy. It takes in the chosen alternative, the second 2 matrices that were previously stored, the number of auctions, and the number of clicks for the hour. It returns updated versions of the 2 matrices to be stored and passed on in the next call to logKG. 

5. At the end of a run of simulations, the 2 matrices put out by **learn_logKG** give you the estimated mean and the inverse of the variance of the coefficients in the logistic function.


### Sample Code ###

KG Policy Considering Next Hour as a Single Period (Sampled Belief Model)

```
#!matlab
[a,b,c] = init_KG();

t_hor = t;

for i=1:N
    bid = KG_hr(a,b,c,t_hor);
    numAucts = n;
    numClicks = m;
    [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
end
```

Multi-step Look-ahead KG Policy Considering Next Auction as a Single Period (Sampled Belief Model)

```
#!matlab
[a,b,c] = init_KG();

t_hor = t;
tau = t2;

for i=1:N
    bid = KG_ms(a,b,c,t_hor,tau);
    numAucts = n;
    numClicks = m;
    [b,c] = learn_KG(bid,b,c,numAucts,numClicks);
end
```

logKG Policy Considering Next Auction as a Single Period (Parametric Belief Model) without Attributes

```
#!matlab
d = 2;
[a,b,c] = init_logKG(d);

t_hor = t;

for i=1:N
    x = logKG(a,b,c,t_hor);
    bid = x(1);
    numAucts = n;
    numClicks = m;
    [b,c] = learn_logKG(x,b,c,numAucts,numClicks);
end
```

logKG Policy Considering Next Auction as a Single Period (Parametric Belief Model) with Location Attributes

```
#!matlab
d = dimensions;
[a,b,c] = init_logKG(d);

t_hor = t;

for i=1:N
    numAucts = n;
    for auct=1:numAucts
        location;
        a_location = locToA(location);
        x = logKG(a_location,b,c,t_hor);
        bid = x(1);
        click = m;
        [b,c] = learn_logKG(x,b,c,1,click);
    end
end
```
