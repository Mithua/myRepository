function [trainedClassifier, validationAccuracy] = trainClassifier_ada_Expert2cat(datasetTable, cy)
%%% Train adaboostM1 classifer using 10-fold CV
predictorNames = {'Dementia', 'Duration', 'Frequency'};
predictors = datasetTable(:, predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.Expert2cat;

%%% Train a classifier
trainedClassifier = fitensemble(predictors, response, 'AdaBoostM1', cy, 'Tree', 'Type', 'Classification', 'LearnRate', 0.1, 'PredictorNames', {'Dementia' 'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1]);
%%% Perform 10-fold CV
partitionedModel = crossval(trainedClassifier, 'KFold', 10);
%%% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
