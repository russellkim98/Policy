# README #

### What is this repository for? ###

* Files for running various policies to decide bid values for auctions on Google Ads

### Requirements ###
 
* MATLAB

### Ready to Use: ###

Knowledge Gradient Policy Considering Next Hour as a Single Period

* Call **initialize_KG** once at the start of a run of simulations to initialize the policy. Takes in no parameters. Returns 3 matrices that should be stored and passed on in the first call to KG_hr. 

* Call **KG_hr** during each simulated hour to choose a bid. Takes in the 3 matrices that were previously stored and a tunable parameter t_hor representing the time horizon. Returns 3 matrices and a bid value, all to be stored and passed on in the next call to learner_KG_hr.
     * When t_hor is large, the policy places an emphasis on the value of learning and the profit you can make after learning; when t_hor is small, the policy places an emphasis the the profit you make while learning.
     * Fix t_hor for each run of simulations.

* Simulate the number of auctions and the number of clicks during each simulated hour.

* Call **learner_KG_hr** during each simulated hour to update the policy. Takes in the 3 matrices that were previously stored, a bid, the number of auctions and the number of clicks for the hour. Returns 3 matrices to be stored and passed on in the next call to KG_hr.

```
#!matlab
[a,b,c] = initialize_KG();

t_hor = t;

for i=1:n
    [a,b,c,bid] = KG_hr(a,b,c,t_hor);
    numAucts = n;
    numClicks = m;
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
end
```

* At the end of a run of simulations, the second and third matrices put out by learner_KG_hr give you the possible truths and their probabilities of being true, respectively. 

Multi-step Look-ahead Knowledge Gradient Policy Considering Next Auction as a Single Period

* Call **initialize_KG** once at the start of a run of simulations to initialize the policy. Takes in no parameters. Returns 3 matrices that should be stored and passed on in the first call to KG_ms. 

* Call **KG_ms** during each simulated hour to choose a bid. Takes in the 3 matrices that were previously stored and 2 tunable parameters t_hor and tau representing the time horizon and the number of auctions to look ahead, respectively. Returns 3 matrices and a bid value, all to be stored and passed on in the next call to learner_KG_hr.
     * When t_hor is large, the policy places an emphasis on the value of learning and the profit you can make after learning; when t_hor is small, the policy places an emphasis the the profit you make while learning.
     * When tau is too large, the policy will look ahead too many auctions with diminishing marginal returns. When tau is too small, the policy isn't looking ahead enough auctions to fully make use of looking ahead. 
     * Fix t_hor and tau for each run of simulations.

* Simulate the number of auctions and the number of clicks during each simulated hour.

* Call **learner_KG_hr** during each simulated hour to update the policy. Takes in the 3 matrices that were previously stored, a bid, the number of auctions and the number of clicks for the hour. Returns 3 matrices to be stored and passed on in the next call to KG_ms.

```
#!matlab
[a,b,c] = initialize_KG();

t_hor = t;
tau = t2;

for i=1:n
    [a,b,c,bid] = KG_ms(a,b,c,t_hor,tau);
    numAucts = n;
    numClicks = m;
    [a,b,c] = learner_KG_hr(a,b,c,bid,numAucts,numClicks);
end
```
* At the end of a run of simulations, the second and third matrices put out by learner_KG_hr give you the possible truths and their probabilities of being true, respectively. 

### Other Functions ###

* KG.m -- MATLAB function. Chooses a bid for the next auction.

* phi.m -- MATLAB function. Logistic function. Estimates probability of getting a clickthrough.

* profit.m -- MATLAB function. Estimates profit after a clickthrough given a bid value.

* update_p.m -- MATLAB function. Updates probability vector of the knowledge gradient policy given a bid and a response from an auction.

* test.m -- MATLAB script for test purposes. 

Archive

* policy_logKG_2.m, policy_logKG_1Hot.m, policy_logKG.m -- MATLAB scripts. Tried to calls Yingfei's logKG function to use a knowledge gradient policy combined with a logistic regression belief model. 

* policy_primitive.m -- MATLAB script. Uses data from SimulatorOutput.csv to come up with optimal bid values for each hour of the week. Uses some of the logic of the original "Vanilla Model" policy.

* SimulatorOutput.csv -- Modified version of ParsedParam.csv in Simulator repository. Includes all data points but only lists hour of the week, auctions, clicks, cost, and value per conversion.

* logisticKG_yingfei -- Folder containing some of Yingfei's work. The logKG.m file implements knowledge gradient policy under logistic belief models. Could be useful when implementing knowledge gradient policy for this project.