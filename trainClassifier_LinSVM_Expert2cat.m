function [trainedClassifier, validationAccuracy] = trainClassifier_LinSVM_Expert2cat(datasetTable, C)
%%% Train linear SVM ('SMO') classifer using 10-fold CV
predictorNames = {'Duration', 'Frequency'};
predictors = datasetTable(:, predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.Expert2cat;

%%% Train a classifier
trainedClassifier = fitcsvm(predictors, response, 'KernelFunction', 'linear', 'PolynomialOrder', [], 'KernelScale', 'auto', 'BoxConstraint', C, 'Standardize', 1, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1]);
%%% Perform 10-fold CV
partitionedModel = crossval(trainedClassifier, 'KFold', 10);
%%% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
