%%% Program to train k-nn classifer using 10-fold CV

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
k = 1:60; % enter fn argument2
n = length(k);
for i = 1:n;
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_knn_Expert2cat(datasetTable, k(i));
end

%%% Plot kora_r jonnye
figure
plot(k, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('k');
ylabel('Accuracy');
title('\bfk-nearest neighbours: 10-fold CV accuracy vs k-nn');

%%% Optimum k value nirman kora
k(find(validationAccuracy == max(validationAccuracy)))
max(validationAccuracy)
% find(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy
