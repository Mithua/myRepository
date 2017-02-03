%%% Program to train Gaussian SVM ('SMO') classifer using 10-fold CV

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
S = linspace(0.5, 10, 20); % enter fn argument3
n = length(C);
m = length(S);
for i = 1:n;
    for j = 1:m;
        [trainedClassifier, validationAccuracy(i, j)] = trainClassifier_GauSVM_Expert2cat(datasetTable, C(i), S(j));
    end
end

%%% Plot kora_r jonnye
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

%%% Optimum C, S values nirman kora
% index => columnwise goné, [PROTHOM maxValue, linearIndexesOfMax] dyay jodi ektar beshi maxValue thake
transmat = validationAccuracy'; % tai ebar rowwise gunbé
[maxValue, linearIndexesOfMaxes] = max(transmat(:))
% use ind2sub() to extract row & column indices corresponding to PROTHOM maxValue
[I_row, I_col] = ind2sub(size(transmat), linearIndexesOfMaxes)
C(I_col) % NOT I_row karon transposed matrix
S(I_row) % NOT I_col karon transposed matrix
validationAccuracy(I_col, I_row) % chk kora
