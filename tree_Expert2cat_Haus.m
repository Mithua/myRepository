%%% Program to train decision tree classifer using 10-fold CV

% F9 to run a highlighted code
clc
format compact

%%% Working directory_te bodlano
cd 'D:\Mit\Thesis MASS\Thesis rough work\Matlab';
pwd

%%% haate kore ActimetryClassification.csv AMDANI kora [sob variables gulo ke COLUMN VECTOR hishebe]

%%% Set seed
rng(5); % random number generator seed_er jonnye

%%% Run loop of different parameter values
datasetTable = table(Duration, Frequency, Expert2cat); % enter fn argument1
mns = 1:100; % enter fn argument2
n = length(mns);
for i = 1:n;
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_tree_Expert2cat(datasetTable, mns(i));
end

%%% Plot kora_r jonnye
figure
plot(mns, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('Max. num. splits');
ylabel('Accuracy');
title('\bfDecision tree: 10-fold CV accuracy vs maximum number of splits');

%%% Optimum maximum number of splits value nirman kora
mns(find(validationAccuracy == max(validationAccuracy)))
max(validationAccuracy)
% find(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy
