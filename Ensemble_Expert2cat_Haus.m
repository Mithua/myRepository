% F9 to run a highlighted code
clc
format compact

%%% Working directory_te bodlano
cd 'D:\Mit\Thesis MASS\Thesis rough work\Matlab';
pwd

%%% haate kore ActimetryClassification.csv AMDANI kora [sob variables gulo ke COLUMN VECTOR hishebe]

% -------------------------------------------------------------------------

%%% BEISPIEL - program to train adaboostM1 classifer using 10-fold CV

%%% Set seed
rng(5); % random number generator seed_er jonnye

%%% Run loop of different parameter values
% onek somoy nyay - 20 minute moton, tai bhebechinte byabohar kora
datasetTable = table(Duration, Frequency, Expert2cat); % enter fn argument1
cy = 1:100; % enter fn argument2
n = length(cy);
for i = 1:n;
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_ada_Expert2cat(datasetTable, cy(i));
end

%%% Plot kora_r jonnye
figure
plot(cy, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('Ensemble size');
ylabel('Accuracy');
title('\bfAdaboostM1: 10-fold CV accuracy vs ensemble size');

%%% Optimum cycles_er value nirman kora
cy(find(validationAccuracy == max(validationAccuracy)))
max(validationAccuracy)
% find(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy

% -------------------------------------------------------------------------

%%% Make AD voor analysië
datasetTable = table(Duration, Frequency, Expert2cat);
predictorNames = {'Duration', 'Frequency'};
predictors = datasetTable(:, predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.Expert2cat;

%%% Program to train ensemble classifers using 10-fold CV

%%% Set seed
rng(5); % random number generator seed_er jonnye

%%% Choose tree template
templateTree = templateTree('MaxNumSplits', 3); % obtained from tree model previously optimised

%%% Accuracy nirman kora - VVI step
adaStump = fitensemble(predictors, response, 'AdaBoostM1', 100, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
totalStump = fitensemble(predictors, response, 'TotalBoost', 100, templateTree, 'Type', 'Classification', 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
lpStump = fitensemble(predictors, response, 'LPBoost', 100, templateTree, 'Type', 'Classification', 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
gentleStump = fitensemble(predictors, response, 'GentleBoost', 100, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
robustStump = fitensemble(predictors, response, 'RobustBoost', 100, templateTree, 'Type', 'Classification', 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
rusStump = fitensemble(predictors, response, 'RUSBoost', 100, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
logitStump = fitensemble(predictors, response, 'LogitBoost', 100, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
subspcStump = fitensemble(predictors, response, 'Subspace', 100, 'Discriminant', 'Type', 'Classification', 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
bagStump = fitensemble(predictors, response, 'Bag', 100, templateTree, 'Type', 'Classification', 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');

%%% Classiferror (default) loss function ~ binodeviance & mincost(except LogitBoost) loss functions
adaAccuracy = 1 - kfoldLoss(adaStump, 'Mode', 'Cumulative');
totalAccuracy = 1 - kfoldLoss(totalStump, 'Mode', 'Cumulative');
lpAccuracy = 1 - kfoldLoss(lpStump, 'Mode', 'Cumulative');
gentleAccuracy = 1 - kfoldLoss(gentleStump, 'Mode', 'Cumulative');
robustAccuracy = 1 - kfoldLoss(robustStump, 'Mode', 'Cumulative');
rusAccuracy = 1 - kfoldLoss(rusStump, 'Mode', 'Cumulative');
logitAccuracy = 1 - kfoldLoss(logitStump, 'Mode', 'Cumulative');
subspcAccuracy = 1 - kfoldLoss(subspcStump, 'Mode', 'Cumulative');
bagAccuracy = 1 - kfoldLoss(bagStump, 'Mode', 'Cumulative');

%%% Accuracy plot kora_r jonnye
figure
plot(adaAccuracy, 'r--'); % learning rate = 0.1
hold on
plot(totalAccuracy, 'b-'); % no learning rate parameter
hold on
plot(lpAccuracy, 'g.-'); % no learning rate parameter
hold on
plot(gentleAccuracy, 'k.'); % learning rate = 0.1
hold on
plot(robustAccuracy, 'm--'); % no learning rate parameter
hold on
plot(rusAccuracy, 'c-'); % learning rate = 0.1
hold on
plot(logitAccuracy, 'y.-'); % learning rate = 0.1
hold on
plot(subspcAccuracy, 'g.'); % discriminant learner (not knn)
hold on
plot(bagAccuracy, 'k-');
hold off
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('Ensemble size');
ylabel('Accuracy (classiferror loss)');
legend('AdaBoost', 'TotalBoost', 'LPBoost', 'GentleBoost', 'RobustBoost', 'RUSBoost', 'LogitBoost', 'Subspace', 'Bagging', 'Location', 'SE');
title('\bfEnsemble learners: 10-fold CV accuracy (classiferror loss) vs ensemble size');

%%% Optimum cycles_er value nirman kora
max(adaAccuracy)
find(adaAccuracy == max(adaAccuracy)) % kon index_e max accuracy hoy
max(totalAccuracy)
find(totalAccuracy == max(totalAccuracy)) % kon index_e max accuracy hoy
max(lpAccuracy)
find(lpAccuracy == max(lpAccuracy)) % kon index_e max accuracy hoy
max(gentleAccuracy)
find(gentleAccuracy == max(gentleAccuracy)) % kon index_e max accuracy hoy
max(robustAccuracy)
find(robustAccuracy == max(robustAccuracy)) % kon index_e max accuracy hoy
max(rusAccuracy)
find(rusAccuracy == max(rusAccuracy)) % kon index_e max accuracy hoy
max(logitAccuracy)
find(logitAccuracy == max(logitAccuracy)) % kon index_e max accuracy hoy
max(subspcAccuracy)
find(subspcAccuracy == max(subspcAccuracy)) % kon index_e max accuracy hoy
max(bagAccuracy)
find(bagAccuracy == max(bagAccuracy)) % kon index_e max accuracy hoy

%%% Alternately, exponential loss function
adaAccuracye = 1 - kfoldLoss(adaStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
totalAccuracye = 1 - kfoldLoss(totalStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
lpAccuracye = 1 - kfoldLoss(lpStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
gentleAccuracye = 1 - kfoldLoss(gentleStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
robustAccuracye = 1 - kfoldLoss(robustStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
rusAccuracye = 1 - kfoldLoss(rusStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
logitAccuracye = 1 - kfoldLoss(logitStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
subspcAccuracye = 1 - kfoldLoss(subspcStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
bagAccuracye = 1 - kfoldLoss(bagStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');

%%% Alternately, accuracy plot kora_r jonnye
figure
plot(adaAccuracye, 'r--'); % learning rate = 0.1
hold on
plot(totalAccuracye, 'b-'); % no learning rate parameter
hold on
plot(lpAccuracye, 'g.-'); % no learning rate parameter
hold on
plot(gentleAccuracye, 'k.'); % learning rate = 0.1
hold on
plot(robustAccuracye, 'm--'); % no learning rate parameter
hold on
plot(rusAccuracye, 'c-'); % learning rate = 0.1
hold on
plot(logitAccuracye, 'y.-'); % learning rate = 0.1
hold on
plot(subspcAccuracye, 'g.'); % discriminant learner (not knn)
hold on
plot(bagAccuracye, 'k-');
hold off
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('Ensemble size');
ylabel('Accuracy (exponential loss)');
legend('AdaBoost', 'TotalBoost', 'LPBoost', 'GentleBoost', 'RobustBoost', 'RUSBoost', 'LogitBoost', 'Subspace', 'Bagging', 'Location', 'SE');
title('\bfEnsemble learners: 10-fold CV accuracy (exponential loss) vs ensemble size');

%%% Alternately, hinge loss function
adaAccuracyh = 1 - kfoldLoss(adaStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
totalAccuracyh = 1 - kfoldLoss(totalStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
lpAccuracyh = 1 - kfoldLoss(lpStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
gentleAccuracyh = 1 - kfoldLoss(gentleStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
robustAccuracyh = 1 - kfoldLoss(robustStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
rusAccuracyh = 1 - kfoldLoss(rusStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
logitAccuracyh = 1 - kfoldLoss(logitStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
subspcAccuracyh = 1 - kfoldLoss(subspcStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
bagAccuracyh = 1 - kfoldLoss(bagStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');

%%% Alternately, accuracy plot kora_r jonnye
figure
plot(adaAccuracyh, 'r--'); % learning rate = 0.1
hold on
plot(totalAccuracyh, 'b-'); % no learning rate parameter
hold on
plot(lpAccuracyh, 'g.-'); % no learning rate parameter
hold on
plot(gentleAccuracyh, 'k.'); % learning rate = 0.1
hold on
plot(robustAccuracyh, 'm--'); % no learning rate parameter
hold on
plot(rusAccuracyh, 'c-'); % learning rate = 0.1
hold on
plot(logitAccuracyh, 'y.-'); % learning rate = 0.1
hold on
plot(subspcAccuracyh, 'g.'); % discriminant learner (not knn)
hold on
plot(bagAccuracyh, 'k-');
hold off
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('Ensemble size');
ylabel('Accuracy (hinge loss)');
legend('AdaBoost', 'TotalBoost', 'LPBoost', 'GentleBoost', 'RobustBoost', 'RUSBoost', 'LogitBoost', 'Subspace', 'Bagging', 'Location', 'SE');
title('\bfEnsemble learners: 10-fold CV accuracy (hinge loss) vs ensemble size');
