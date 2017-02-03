function [trainedClassifier, validationAccuracy] = trainClassifier_tree_Expert2cat(datasetTable, mns)
%%% Train decision tree classifer using 10-fold CV
predictorNames = {'Duration', 'Frequency'};
predictors = datasetTable(:, predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.Expert2cat;

%%% Train a classifier
trainedClassifier = fitctree(predictors, response, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'SplitCriterion', 'deviance', 'MaxNumSplits', mns, 'Surrogate', 'off');
%%% Perform 10-fold CV
partitionedModel = crossval(trainedClassifier, 'KFold', 10);
%%% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
