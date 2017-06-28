# README #

### What is this repository for? ###

* Files for running various policies to decide bid values for auctions on Google Ads

### Description of (Current Version of) Files ###

* initialize_KG.m -- MATLAB function. Initializes knowledge gradient policy. Meant to be called once at the start of a run of simulations. Returns 3 matrices that should be stored and passed on in the first call to KG. 

* KG.m -- MATLAB function. Chooses a bid using the knowledge gradient policy. Takes in 3 matrices and returns 3 matrices and a bid value, all to be stored and passed on in the next call to learner_KG. 

* learner_KG.m -- MATLAB function. Updates the knowledge gradient policy to reflect most recent bid and response. Takes in 3 matrices, a bid and its response. Returns 3 matrices to be stored and passed on in the next call to KG. 

Helper functions:

* phi.m -- MATLAB function. Logistic function. 

* profit.m -- MATLAB function. Estimates profit after a clickthrough given a bid value.

* update_p.m -- MATLAB function. Updates probability vector of the knowledge gradient policy given a bid and a response.

Archive:
* policy_logKG_2.m, policy_logKG_1Hot.m, policy_logKG.m -- MATLAB scripts. Tried to calls Yingfei's logKG function to use a knowledge gradient policy combined with a logistic regression belief model. 

* policy_primitive.m -- MATLAB script. Uses data from SimulatorOutput.csv to come up with optimal bid values for each hour of the week. Uses some of the logic of the original "Vanilla Model" policy.

* SimulatorOutput.csv -- Modified version of ParsedParam.csv in Simulator repository. Includes all data points but only lists hour of the week, auctions, clicks, cost, and value per conversion.

* logisticKG_yingfei -- Folder containing some of Yingfei's work. The logKG.m file implements knowledge gradient policy under logistic belief models. Could be useful when implementing knowledge gradient policy for this project.