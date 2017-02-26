%% Clean previous work
clear
clc
format compact

%% Dataset_er directory_te bodlano
cd 'D:\Mit\Thesis MASS\Thesis rough work';
pwd

%% Import data from text file
%% Initialise variables
filename = 'D:\Mit\Thesis MASS\Thesis rough work\ActimetryClassification.csv';
delimiter = ',';
startRow = 2;

%% Format for each line of text
formatSpec = '%f%f%f%f%*s%*s%f%*s%[^\n\r]';

%% Open the text file
fileID = fopen(filename, 'r');

%% Read columns of data according to the format
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines', startRow - 1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file
fclose(fileID);

%% Post processing for unimportable data
%% Allocate imported array to column variable names
Patid = dataArray{:, 1};
Dementia = dataArray{:, 2};
Frequency = dataArray{:, 3};
Duration = dataArray{:, 4};
Expert2cat = dataArray{:, 5};

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray;

%% Set random seed
rng(12345);

%% Join the columns into a table
datasetTable = table(Dementia, Duration, Frequency, Expert2cat); % fn argument1

%% Dataset_er directory_te bodlano
cd 'C:\Users\mit_7_000\Downloads\Data Mining Deep Learning\HW Projekt\Matlab';
pwd
clearvars ans;





%% Program to train naïve Bayes classifer using 10-fold CV
% Dementia has zero-variance, so not used
[trainedClassifier, validationAccuracy] = trainClassifier_nb_Expert2cat(datasetTable);
nb_CVaccuracy = validationAccuracy;


%% Program to train linear SVM classifer using 10-fold CV
%% Run loop of different parameter values
validationAccuracy = 0; %!!!
C = linspace(0.01, 20, 20); % fn argument2
n = length(C);
for i = 1:n
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_LinSVM_Expert2cat(datasetTable, C(i));
end

%% Plot kora_r jonnye
figure
plot(C, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('C');
ylabel('CV accuracy');
title('\bfLinear SVM using "SMO": 10-fold CV accuracy vs cost (C) parameter');

%% Optimum C value nirman kora
C(validationAccuracy == max(validationAccuracy))
linSVM_CVaccuracy = max(validationAccuracy);
find(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy


%% Program to train Quadratic SVM classifer using 10-fold CV
%% Run loop of different parameter values
validationAccuracy = 0; %!!!
C = linspace(0.01, 20, 20); % fn argument2
n = length(C);
for i = 1:n
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_QuadSVM_Expert2cat(datasetTable, C(i));
end

%% Plot kora_r jonnye
figure
plot(C, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('C');
ylabel('CV accuracy');
title('\bfQuadratic SVM using "SMO": 10-fold CV accuracy vs cost (C) parameter');

%% Optimum C value nirman kora
C(validationAccuracy == max(validationAccuracy))
quadSVM_CVaccuracy = max(validationAccuracy);
find(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy


%% Program to train Cubic SVM classifer using 10-fold CV
%% Run loop of different parameter values
validationAccuracy = 0; %!!!
C = linspace(0.01, 20, 20); % fn argument2
n = length(C);
for i = 1:n
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_QuadSVM_Expert2cat(datasetTable, C(i));
end

%% Plot kora_r jonnye
figure
plot(C, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('C');
ylabel('CV accuracy');
title('\bfCubic SVM using "SMO": 10-fold CV accuracy vs cost (C) parameter');

%% Optimum C value nirman kora
C(validationAccuracy == max(validationAccuracy))
quadSVM_CVaccuracy = max(validationAccuracy);
find(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy


%% Program to train Gaussian SVM classifer using 10-fold CV
%% Run loop of different parameter values
validationAccuracy = 0; %!!!
C = linspace(0.01, 20, 20); % fn argument2
S = linspace(0.5, 10, 20); % fn argument3
n = length(C);
m = length(S);
for i = 1:n
    for j = 1:m
        [trainedClassifier, validationAccuracy(i, j)] = trainClassifier_GauSVM_Expert2cat(datasetTable, C(i), S(j));
    end
end

%% Plot kora_r jonnye
figure
[X, Y] = ndgrid(C, S); % cf. ndgrid() vs meshgrid() format
F = griddedInterpolant(X, Y, validationAccuracy, 'spline'); % interpolating F() toiri kora
[Xq, Yq] = ndgrid(0.01:0.1:20, 0.5:0.1:10);
Vq = F(Xq, Yq);
surf(Xq, Yq, Vq);
xlabel('C');
ylabel('Scale');
zlabel('Accuracy');
title('\bfGaussian SVM using "SMO": 10-fold CV accuracy vs cost & kernel scale');

%% Optimum C, S values nirman kora
% index => columnwise goné, [PROTHOM maxValue, linearIndexesOfMax] dyay jodi ektar beshi maxValue thake
transmat = validationAccuracy'; % tai ebar rowwise gunbé
[maxValue, linearIndexesOfMaxes] = max(transmat(:))
% use ind2sub() to extract row & column indices corresponding to PROTHOM maxValue
[I_row, I_col] = ind2sub(size(transmat), linearIndexesOfMaxes)
C(I_col) % NOT I_row karon transposed matrix
S(I_row) % NOT I_col karon transposed matrix
gauSVM_CVaccuracy = validationAccuracy(I_col, I_row);


%% Program to train decision tree using 10-fold CV
%% Run loop of different parameter values
validationAccuracy = 0; %!!!
mns = 1:100; % fn argument2
n = length(mns);
for i = 1:n
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_tree_Expert2cat(datasetTable, mns(i));
end

%% Plot kora_r jonnye
figure
plot(mns, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('Max. num. splits');
ylabel('Accuracy');
title('\bfDecision tree: 10-fold CV accuracy vs maximum number of splits');

%% Optimum maximum number of splits value nirman kora
mns(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy
tree_CVaccuracy = max(validationAccuracy);


%% Program to train k-nearest neighbours using 10-fold CV
%% Run loop of different parameter values
validationAccuracy = 0; %!!!
k = 1:60; % fn argument2
n = length(k);
for i = 1:n
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_knn_Expert2cat(datasetTable, k(i));
end

%% Plot kora_r jonnye
figure
plot(k, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('k');
ylabel('Accuracy');
title('\bfk-nearest neighbours: 10-fold CV accuracy vs k-nn');

%% Optimum k value nirman kora
k(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy
knn_CVaccuracy = max(validationAccuracy);


%% Program to train ADA boost model using 10-fold CV
%% Run loop of different parameter values
validationAccuracy = 0; %!!!
% onek somoy nyay - 10 minute moton, tai bhebechinte byabohar kora
cy = 1:60; % fn argument2
n = length(cy);
for i = 1:n
    [trainedClassifier, validationAccuracy(i)] = trainClassifier_ada_Expert2cat(datasetTable, cy(i));
end

%% Plot kora_r jonnye
figure
plot(cy, validationAccuracy, 'r.--');
h = gca;
lims = [h.XLim h.YLim]; % extract x and y axes limits
xlabel('Ensemble size');
ylabel('Accuracy');
title('\bfAdaboostM1: 10-fold CV accuracy vs ensemble size');

%% Optimum cycles_er value nirman kora
cy(validationAccuracy == max(validationAccuracy)) % kon index_e max accuracy hoy
ada_CVaccuracy0 = max(validationAccuracy);


% -------------------------------------------------------------------------


%% Ensemble models
% datasetTable = table(Duration, Frequency, Expert2cat);
predictorNames = {'Dementia', 'Duration', 'Frequency'};
predictors = datasetTable(:, predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.Expert2cat;

%% Program to train ensemble classifers using 10-fold CV
%% Choose tree template
templateTree = templateTree('MaxNumSplits', 3); % obtained from tree model previously optimised

%% Accuracy nirman kora - VVI step
adaStump = fitensemble(predictors, response, 'AdaBoostM1', 60, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
totalStump = fitensemble(predictors, response, 'TotalBoost', 60, templateTree, 'Type', 'Classification', 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
lpStump = fitensemble(predictors, response, 'LPBoost', 60, templateTree, 'Type', 'Classification', 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
gentleStump = fitensemble(predictors, response, 'GentleBoost', 60, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
robustStump = fitensemble(predictors, response, 'RobustBoost', 60, templateTree, 'Type', 'Classification', 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
rusStump = fitensemble(predictors, response, 'RUSBoost', 60, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
logitStump = fitensemble(predictors, response, 'LogitBoost', 60, templateTree, 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
subspcStump = fitensemble(predictors, response, 'Subspace', 60, 'Discriminant', 'Type', 'Classification', 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');
bagStump = fitensemble(predictors, response, 'Bag', 60, templateTree, 'Type', 'Classification', 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'CrossVal', 'on');

%% Classiferror (default) loss function ~ binodeviance & mincost(except LogitBoost) loss functions
adaAccuracy = 1 - kfoldLoss(adaStump, 'Mode', 'Cumulative');
totalAccuracy = 1 - kfoldLoss(totalStump, 'Mode', 'Cumulative');
lpAccuracy = 1 - kfoldLoss(lpStump, 'Mode', 'Cumulative');
gentleAccuracy = 1 - kfoldLoss(gentleStump, 'Mode', 'Cumulative');
robustAccuracy = 1 - kfoldLoss(robustStump, 'Mode', 'Cumulative');
rusAccuracy = 1 - kfoldLoss(rusStump, 'Mode', 'Cumulative');
logitAccuracy = 1 - kfoldLoss(logitStump, 'Mode', 'Cumulative');
subspcAccuracy = 1 - kfoldLoss(subspcStump, 'Mode', 'Cumulative');
bagAccuracy = 1 - kfoldLoss(bagStump, 'Mode', 'Cumulative');

%% Accuracy plot kora_r jonnye
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

%% Optimum cycles_er value nirman kora
ada_CVaccuracy = max(adaAccuracy);
find(adaAccuracy == max(adaAccuracy)) % kon index_e max accuracy hoy
total_CVaccuracy = max(totalAccuracy);
find(totalAccuracy == max(totalAccuracy)) % kon index_e max accuracy hoy
lp_CVaccuracy = max(lpAccuracy);
find(lpAccuracy == max(lpAccuracy)) % kon index_e max accuracy hoy
gentle_CVaccuracy = max(gentleAccuracy);
find(gentleAccuracy == max(gentleAccuracy)) % kon index_e max accuracy hoy
robust_CVaccuracy = max(robustAccuracy);
find(robustAccuracy == max(robustAccuracy)) % kon index_e max accuracy hoy
rus_CVaccuracy = max(rusAccuracy);
find(rusAccuracy == max(rusAccuracy)) % kon index_e max accuracy hoy
logit_CVaccuracy = max(logitAccuracy);
find(logitAccuracy == max(logitAccuracy)) % kon index_e max accuracy hoy
subspc_CVaccuracy = max(subspcAccuracy);
find(subspcAccuracy == max(subspcAccuracy)) % kon index_e max accuracy hoy
bag_CVaccuracy = max(bagAccuracy);
find(bagAccuracy == max(bagAccuracy)) % kon index_e max accuracy hoy

%% Alternately, exponential loss function
adaAccuracye = 1 - kfoldLoss(adaStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
totalAccuracye = 1 - kfoldLoss(totalStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
lpAccuracye = 1 - kfoldLoss(lpStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
gentleAccuracye = 1 - kfoldLoss(gentleStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
robustAccuracye = 1 - kfoldLoss(robustStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
rusAccuracye = 1 - kfoldLoss(rusStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
logitAccuracye = 1 - kfoldLoss(logitStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
subspcAccuracye = 1 - kfoldLoss(subspcStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');
bagAccuracye = 1 - kfoldLoss(bagStump, 'Mode', 'Cumulative', 'LossFun', 'exponential');

%% Alternately, accuracy plot kora_r jonnye
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

%% Optimum cycles_er value nirman kora
ada_CVaccuracye = max(adaAccuracye);
find(adaAccuracye == max(adaAccuracye)) % kon index_e max accuracy hoy
total_CVaccuracye = max(totalAccuracye);
find(totalAccuracye == max(totalAccuracye)) % kon index_e max accuracy hoy
lp_CVaccuracye = max(lpAccuracye);
find(lpAccuracye == max(lpAccuracye)) % kon index_e max accuracy hoy
gentle_CVaccuracye = max(gentleAccuracye);
find(gentleAccuracye == max(gentleAccuracye)) % kon index_e max accuracy hoy
robust_CVaccuracye = max(robustAccuracye);
find(robustAccuracye == max(robustAccuracye)) % kon index_e max accuracy hoy
rus_CVaccuracye = max(rusAccuracye);
find(rusAccuracye == max(rusAccuracye)) % kon index_e max accuracy hoy
logit_CVaccuracye = max(logitAccuracye);
find(logitAccuracye == max(logitAccuracye)) % kon index_e max accuracy hoy
subspc_CVaccuracye = max(subspcAccuracye);
find(subspcAccuracye == max(subspcAccuracye)) % kon index_e max accuracy hoy
bag_CVaccuracye = max(bagAccuracye);
find(bagAccuracye == max(bagAccuracye)) % kon index_e max accuracy hoy

%% Alternately, hinge loss function
adaAccuracyh = 1 - kfoldLoss(adaStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
totalAccuracyh = 1 - kfoldLoss(totalStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
lpAccuracyh = 1 - kfoldLoss(lpStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
gentleAccuracyh = 1 - kfoldLoss(gentleStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
robustAccuracyh = 1 - kfoldLoss(robustStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
rusAccuracyh = 1 - kfoldLoss(rusStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
logitAccuracyh = 1 - kfoldLoss(logitStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
subspcAccuracyh = 1 - kfoldLoss(subspcStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');
bagAccuracyh = 1 - kfoldLoss(bagStump, 'Mode', 'Cumulative', 'LossFun', 'hinge');

%% Alternately, accuracy plot kora_r jonnye
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

%% Optimum cycles_er value nirman kora
ada_CVaccuracyh = max(adaAccuracyh);
find(adaAccuracyh == max(adaAccuracyh)) % kon index_e max accuracy hoy
total_CVaccuracyh = max(totalAccuracyh);
find(totalAccuracyh == max(totalAccuracyh)) % kon index_e max accuracy hoy
lp_CVaccuracyh = max(lpAccuracyh);
find(lpAccuracyh == max(lpAccuracyh)) % kon index_e max accuracy hoy
gentle_CVaccuracyh = max(gentleAccuracyh);
find(gentleAccuracyh == max(gentleAccuracyh)) % kon index_e max accuracy hoy
robust_CVaccuracyh = max(robustAccuracyh);
find(robustAccuracyh == max(robustAccuracyh)) % kon index_e max accuracy hoy
rus_CVaccuracyh = max(rusAccuracyh);
find(rusAccuracyh == max(rusAccuracyh)) % kon index_e max accuracy hoy
logit_CVaccuracyh = max(logitAccuracyh);
find(logitAccuracyh == max(logitAccuracyh)) % kon index_e max accuracy hoy
subspc_CVaccuracyh = max(subspcAccuracyh);
find(subspcAccuracyh == max(subspcAccuracyh)) % kon index_e max accuracy hoy
bag_CVaccuracyh = max(bagAccuracyh);
find(bagAccuracyh == max(bagAccuracyh)) % kon index_e max accuracy hoy
