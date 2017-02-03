function [trainedClassifier, validationAccuracy] = trainClassifier_knn_Expert2cat(datasetTable, k)
%%% Train k-nn classifer using 10-fold CV
predictorNames = {'Duration', 'Frequency'};
predictors = datasetTable(:, predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.Expert2cat;

%%% Train a classifier
trainedClassifier = fitcknn(predictors, response, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'Distance', 'Minkowski', 'Exponent', 3, 'NumNeighbors', k, 'DistanceWeight', 'Equal', 'StandardizeData', 1);
% trainedClassifier = fitcknn(predictors, response, 'PredictorNames', {'Duration' 'Frequency'}, 'ResponseName', 'Expert2cat', 'ClassNames', [0 1], 'Distance', 'Euclidean', 'Exponent', '', 'NumNeighbors', k, 'DistanceWeight', 'Inverse', 'StandardizeData', 1);
%%% Perform 10-fold CV
partitionedModel = crossval(trainedClassifier, 'KFold', 10);
%%% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
