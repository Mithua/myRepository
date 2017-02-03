%%% Program to train cubic SVM ('SMO') classifer using 10-fold CV

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
C = linspace(0.01, 20, 20); % enter fn argument2
n = length(C);
for i = 1:n;
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_CubSVM_Expert2cat(datasetTable, C(i));
end

%%% Plot kora_r jonnye
figure
plot(C, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('C');
ylabel('Accuracy');
title('\bfCubic SVM using "SMO": 10-fold CV accuracy vs cost (C) parameter');

%%% Optimum C value nirman kora
C(find(validationAccuracy == max(validationAccuracy)))
max(validationAccuracy)
find(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy
