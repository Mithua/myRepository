%%% Program to train naïve Bayes classifer using 10-fold CV

% F9 to run a highlighted code
clc
format compact

%%% Working directory_te bodlano
cd 'D:\Mit\Thesis MASS\Thesis rough work\Matlab';
pwd

%%% haate kore ActimetryClassification.csv AMDANI kora [sob variables gulo ke COLUMN VECTOR hishebe]

%%% Set seed
rng(5); % random number generator seed_er jonnye

%%% fit model
datasetTable = table(Duration, Frequency, Expert2cat); % enter fn argument1
[trainedClassifier, validationAccuracy] = trainClassifier_nb_Expert2cat(datasetTable);

validationAccuracy
