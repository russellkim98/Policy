# README #

### What is this repository for? ###

* Files for running various policies to decide bid values for auctions on Google Ads

### Description of Files ###

* policy_primitive.m -- MATLAB script. Uses data from SimulatorOutput.csv to come up with optimal bid values for each hour of the week. Uses some of the logic of the original "Vanilla Model" policy.

* SimulatorOutput.csv -- Modified version of ParsedParam.csv in Simulator repository. Includes all data points but only lists hour of the week, auctions, clicks, cost, and value per conversion.

* logisticKG_yingfei -- Folder containing some of Yingfei's work. The logKG.m file implements knowledge gradient policy under logistic belief models. Could be useful when implementing knowledge gradient policy for this project.