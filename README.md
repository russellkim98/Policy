# README #

### What is this repository for? ###

* Files for running various policies to decide bid values for auctions on Google Ads

### Description of (Current Version of) Files ###

* initialize_KG.m -- MATLAB function. Initializes knowledge gradient policy. Meant to be called once at the start of a run of simulations. Returns 3 matrices that should be stored and passed on in the first call to KG_hr or KG_ms. 

* KG_hr.m -- MATLAB function. Chooses a bid for the next hour using the knowledge gradient policy considering the next hour as a single period. Takes in 3 matrices a tunable parameter t_hor. Returns 3 matrices and a bid value, all to be stored and passed on in the next call to learner_KG_hr.

* KG_ms.m -- MATLAB function. Chooses a bid for the next hour using the knowledge gradient policy considering the next auction as a single period and looking ahead tau auctions. Takes in 3 matrices and 2 tunable parameters t_hor and tau. Returns 3 matrices and a bid value, all to be stored and passed on in the next call to learner_KG_hr.

* learner_KG_hr.m -- MATLAB function. Updates the knowledge gradient policy to reflect most recent bid and hour. Takes in 3 matrices, a bid, number of auctions and number of clicks for the hour. Returns 3 matrices to be stored and passed on in the next call to KG_hr or KG_ms.

Other functions:

* KG.m -- MATLAB function. Chooses a bid for the next auction.

* phi.m -- MATLAB function. Logistic function. Estimates probability of getting a clickthrough.

* profit.m -- MATLAB function. Estimates profit after a clickthrough given a bid value.

* update_p_hr.m -- MATLAB function. Updates probability vector of the knowledge gradient policy for a bid and responses over the hour. 

* update_p.m -- MATLAB function. Updates probability vector of the knowledge gradient policy given a bid and a response from an auction.

* test.m -- MATLAB script for test purposes. 

Archive:

* policy_logKG_2.m, policy_logKG_1Hot.m, policy_logKG.m -- MATLAB scripts. Tried to calls Yingfei's logKG function to use a knowledge gradient policy combined with a logistic regression belief model. 

* policy_primitive.m -- MATLAB script. Uses data from SimulatorOutput.csv to come up with optimal bid values for each hour of the week. Uses some of the logic of the original "Vanilla Model" policy.

* SimulatorOutput.csv -- Modified version of ParsedParam.csv in Simulator repository. Includes all data points but only lists hour of the week, auctions, clicks, cost, and value per conversion.

* logisticKG_yingfei -- Folder containing some of Yingfei's work. The logKG.m file implements knowledge gradient policy under logistic belief models. Could be useful when implementing knowledge gradient policy for this project.