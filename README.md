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

1. Call **initialize_KG** or **init_logKG** once at the start of a run of simulations to initialize a policy.
    * **initialize_KG** takes in no parameters. It returns 3 matrices that should be stored and passed on in the first call to KG_hr or KG_ms.
    * **init_logKG** takes in an integer value representing the dimension of the problem. It returns 3 matrices that should be stored and passed on to the first call to logKG.
        * Without any location attributes, the dimension of the problem for **init_logKG** is 2 (representing a logistic function with a constant and one variable representing the bid value).
        * With location attributes, the dimension is 1 + the number of indicator variables in play. For example, if data is coming from 5 distinct cities (all in the same region/country), d = 6. Additionally, the first matrix that is returned from **init_logKG** is modified before being passed on logKG.

2. Call **KG_hr**, **KG_ms**, or **logKG** during each simulated hour to choose a bid. Each take in a tunable parameter t_hor representing the time horizon. When t_hor is large, the policy places an emphasis on the value of learning and the profit you can make after learning; when t_hor is small, the policy places an emphasis the the profit you make while learning. Fix any tunable parameters for each run of simulations.
    * Both **KG_hr** and **KG_ms** take in the exact 3 matrices that were previously stored and t_hor. Both also return 3 matrices and a bid value, all to be stored and passed on in the next call to learner_KG_hr.
        * **KG_ms** takes in an additional tunable parameter tau representing the number of auctions to look ahead. When tau is too large, the policy will look ahead too many auctions with diminishing marginal returns. When tau is too small, the policy isn't looking ahead enough auctions to fully make use of looking ahead. 
    * **logKG** takes in 3 matrices that were previously stored and t_hor. It returns a vector representing the chosen alternative and 2 matrices, all to be stored and passed on exactly in the next call to learner_logKG. The first value in the first vector returned by **logKG** is the bid value. 
        * Without any location attributes, **logKG** takes in the exact 3 matrices that were previously stored.
        * With location attributes, the first matrix that was previously stored is modified to turn "on" the indicator variables representing the location. That is, before each call to **logKG**, a location is decided. Only the indicator variable(s) corresponding with that location are turned on in the first matrix. The other two matrices that were previously stored are passed on exactly to **logKG**.

3. Simulate the number of auctions and the number of clicks during each simulated hour.

4. Call **learner_KG_hr** or **learner_logKG** during each simulated hour to update the policy. **learner_KG_hr** takes in the 3 matrices that were previously stored, a bid, the number of auctions and the number of clicks for the hour. **learner_logKG** takes in the 3 matrices that were previously stored, the number of auctions, and the number of clicks for the hour (the bid value is already in the first matrix). **learner_KG_hr** returns 3 matrices to be stored and passed on in the next call to KG_hr or KG_ms. **learner_logKG** returns 2 matrices to be stored and passed on in the next call to logKG. 

5. At the end of a run of simulations, the second and third matrices put out by **learner_KG_hr** give you the possible truths and their probabilities of being true, respectively. The two matrices put out by **learner_logKG** give you the estimated mean and the inverse of the variance of the coefficients in the logistic function.

### Sample Code ###

Knowledge Gradient Policy Considering Next Hour as a Single Period (Sampled Belief Model)

```
#!matlab
[a,b,c] = initialize_KG();

t_hor = t;

for i=1:N
    [a,b,c,bid] = KG_hr(a,b,c,t_hor);
    numAucts = n;
    numClicks = m;
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
end
```

Multi-step Look-ahead Knowledge Gradient Policy Considering Next Auction as a Single Period (Sampled Belief Model)

```
#!matlab
[a,b,c] = initialize_KG();

t_hor = t;
tau = t2;

for i=1:N
    [a,b,c,bid] = KG_ms(a,b,c,t_hor,tau);
    numAucts = n;
    numClicks = m;
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
end
```

Knowledge Gradient Policy Considering Next Auction as a Single Period (Parametric Belief Model) without Location Attributes

```
#!matlab
[a,b,c] = init_logKG(2);

t_hor = t;

for i=1:N
    [x,b,c] = logKG(a,b,c,t_hor);
    bid = x(1);
    numAucts = n;
    numClicks = m;
    [b,c] = learner_logKG(x,b,c,numAucts,numClicks);
end
```

Knowledge Gradient Policy Considering Next Auction as a Single Period (Parametric Belief Model) with Location Attributes

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
        [x,b,c] = logKG(a_location,b,c,t_hor);
        bid = x(1);
        click = m;
        [b,c] = learner_logKG(x,b,c,1,click);
    end
end
```
