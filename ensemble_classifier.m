function ensemble_classifier(cover_fea, stego_fea, num_train)


cover = load(cover_fea);
stego = load(stego_fea);

names = intersect(cover.names,stego.names);
names = sort(names);

% Prepare cover features C
cover_names = cover.names(ismember(cover.names,names));
[cover_names,ix] = sort(cover_names);
C = cover.F(ismember(cover.names,names),:);
C = C(ix,:);

% Prepare stego features S
stego_names = stego.names(ismember(stego.names,names));
[stego_names,ix] = sort(stego_names);
S = stego.F(ismember(stego.names,names),:);
S = S(ix,:);

% Now we can prepare a training set and a testing set. 

% PRNG initialization with seed 1
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1));

% Division into training/testing set (half/half & preserving pairs)
random_permutation = randperm(size(C,1));
% training_set = random_permutation(1:round(size(C,1)/2));
% testing_set = random_permutation(round(size(C,1)/2)+1:end);
training_set = random_permutation(1:num_train);
testing_set = random_permutation(num_train+1:end);
training_names = names(training_set);
testing_names = names(testing_set);

% Prepare training features
TRN_cover = C(training_set,:);
TRN_stego = S(training_set,:);

% Prepare testing features
TST_cover = C(testing_set,:);
TST_stego = S(testing_set,:);

% Train ensemble with all settings default - automatic search for the
% optimal subspace dimensionality (d_sub), automatic stopping criterion for
% the number of base learners (L), both PRNG seeds (for subspaces and
% bootstrap samples) are initialized randomly.
[trained_ensemble,results] = ensemble_training(TRN_cover,TRN_stego);

% Testing phase - we can conveniently test on cover and stego features
% separately
test_results_cover = ensemble_testing(TST_cover,trained_ensemble);
test_results_stego = ensemble_testing(TST_stego,trained_ensemble);

% Predictions: -1 stands for cover, +1 for stego
false_alarms = sum(test_results_cover.predictions~=-1);
missed_detections = sum(test_results_stego.predictions~=+1);
num_testing_samples = size(TST_cover,1)+size(TST_stego,1);
testing_error = (false_alarms + missed_detections)/num_testing_samples;
fprintf('Testing error: %.4f\n',testing_error);

% ROC curve can be obtain using the following code
labels = [-ones(size(TST_cover,1),1);ones(size(TST_stego,1),1)];
votes  = [test_results_cover.votes;test_results_stego.votes];
[X,Y,T,auc] = perfcurve(labels,votes,1);
% figure(4);clf;plot(X,Y);hold on;plot([0 1],[0 1],':k');
% xlabel('False positive rate'); ylabel('True positive rate');title('ROC');
% legend(sprintf('AUC = %.4f',auc));

% Now, let's go back to the ensemble training. In the rest of this
% tutorial, we will show how to modify individual ensemble parameters.

% First, we can fix the random subspace dimensionality (d_sub) in order to
% avoid the expensive search. This can be useful for a fast research
% feedback.
dim = results.optimal_d_sub;
settings = struct('d_sub',dim);
[~,results] = ensemble_training(TRN_cover,TRN_stego,settings);

% The number of base learners (L) can be also fixed:
settings = struct('d_sub',dim,'L',30);
[~,results] = ensemble_training(TRN_cover,TRN_stego,settings);

% Note: even for the fixed training data, resulting trained ensemble can
% have slightly different performance due to the stochastic components of
% bagging and random subspaces. The following loop executes ensemble
% training 10 times and outputs the average OOB error and its standard
% deviation.

settings = struct('d_sub',dim,'L',30);
OOB = zeros(1,30);
for i=1:30
    [~,results] = ensemble_training(TRN_cover,TRN_stego,settings);
    OOB(i) = results.optimal_OOB;
end
fprintf('# -------------------------\n');
fprintf('Average OOB error = %.5f (+/- %.5f)\n',mean(OOB),std(OOB));

% Sometimes it may be useful to manually set the PRNG seeds for generating
% random subspaces and feature subsets for bagging. This will make the
% results fully reproducible. The following code, for example, should give
% the OOB error 0.1138:
settings = struct('d_sub',dim,'L',30,'seed_subspaces',5,'seed_bootstrap',73);
[~,results] = ensemble_training(TRN_cover,TRN_stego,settings);

% You can fully suppress the ensemble output by setting 'verbose' to 0:
settings = struct('d_sub',dim,'L',30,'verbose',0);
[~,results] = ensemble_training(TRN_cover,TRN_stego,settings);
fprintf('OOB error = %.4f\n',results.optimal_OOB);

% Alternatively, you can suppress everyting BUT the last line of the
% ensemble output (the one with the results) by setting 'verbose' to 2:
settings = struct('d_sub',dim,'L',30,'verbose',2);
[~,results] = ensemble_training(TRN_cover,TRN_stego,settings);

% That's pretty much it. For reporting steganalysis results, it is a good
% habit to repeat the experiment several times (for example 10 times) for
% different training/testing splits. To speed-up the following example, we
% fix d_sub to 300:

tic
testing_errors = zeros(1,30);
settings = struct('d_sub',dim,'verbose',2);
for seed = 1:30
    RandStream.setGlobalStream(RandStream('mt19937ar','Seed',seed));
    random_permutation = randperm(size(C,1));
    training_set = random_permutation(1:num_train);
    testing_set = random_permutation(num_train+1:end);
    TRN_cover = C(training_set,:);
    TRN_stego = S(training_set,:);
    TST_cover = C(testing_set,:);
    TST_stego = S(testing_set,:);
    [trained_ensemble,results] = ensemble_training(TRN_cover,TRN_stego,settings);
    test_results_cover = ensemble_testing(TST_cover,trained_ensemble);
    test_results_stego = ensemble_testing(TST_stego,trained_ensemble);
    false_alarms = sum(test_results_cover.predictions~=-1);
    missed_detections = sum(test_results_stego.predictions~=+1);
    num_testing_samples = size(TST_cover,1)+size(TST_stego,1);
    testing_errors(seed) = (false_alarms + missed_detections)/num_testing_samples;
    fprintf('Testing error %i: %.4f\n',seed,testing_errors(seed));
end
toc
fprintf('---\nAverage testing error over 30 splits: %.4f (+/- %.4f)\n',mean(testing_errors),std(testing_errors));
fprintf('---\nMedian testing error over 30 splits: %.4f (+/- %.4f)\n',median(testing_errors),std(testing_errors));
fid = fopen('results.txt', 'at');
fprintf(fid, 'median testing error %.4f(+/-%.4f)\n', median(testing_errors), std(testing_errors));
fclose(fid);
