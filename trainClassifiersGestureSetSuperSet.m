%% Run classification on different gesture sets saving test set results
%% and classifiers generated to savePath
% Trains: KNN, LDA, SVM-RBF, SVM-L and DT classifiers (see readme)
% Requires features to have been extracted with extractFeatures.m
% Requires gesture array to be updated by extractGesture.m
% Requires repetition array to be updated by extractRepetition.m
% Requires a gestureOrder array generated by getGestureOrders.m
%
% Estimated run time: Days (10min - 8 hours per gesture set depending on number of gestures)
% Optionally classifiers can be saved (uncomment code) however these files will be large (up to >300mb)
% Adam Hartwell 2016


%% Housekeeping
clear; clc;

%% Settings
addpath('db1_feat') % Database path: ***EDIT ACCORDIGNLY***
addpath('gesture') % Gesture array path: ***EDIT ACCORDIGNLY***
addpath('gestureOrders') % Gesture order array path: ***EDIT ACCORDIGNLY***
addpath('repetition') % Repetition array path: ***EDIT ACCORDIGNLY***

savePath = 'results'; % Save path: ***EDIT ACCORDIGNLY***

gestureOrderPair = {'gestureOrderSupersetMAV' 'Superset'} ;  % File_name-label for gesture order: ***EDIT ACCORDIGNLY***

featureSets = {'MAV' 'emgMAV'; % Easily expandable to more feature-array_name pairs
               %'MDWT' 'emgMDWT' % Example extension
               };

knnNeighbours = 10;
subSampleRate = 10;
standardise = true;

trainReps = [1 3 5 7 9];
testingReps = [2 4 6 8 10];

%% Important stuff
rng(1); % For reproducibility

%% Output Data
predictions = cell(27,size(featureSets,1),5);
classifiers = cell(27,size(featureSets,1),5);
testClassesAll = cell(27,5);

for feature = 1:size(featureSets,1)
    eval(['load ' gestureOrderPair{1}]); % Load gesture order
    for numGesturesToUse = 2:53
        tic
        numGesturesToUse
        %% Loop through all subjects
        for subject=1:27
            %% Pre-Amble %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            eval(['load s' num2str(subject) '_feat.mat']); % Load data
            eval(['load s' num2str(subject) '_rep.mat']); % Load relabelled repetitions
            eval(['load s' num2str(subject) '_gestureMajority.mat']); % Load gestures (majority)

            %% Remove gestures we're not using
            unUsedGestures = gestureOrder(subject,1,numGesturesToUse+1:end);
            indicesToRemove = ismember(gesture,unUsedGestures);

            gesture(indicesToRemove) = [];
            rep(indicesToRemove) = [];
            for ii=1:size(featureSets,1)
                eval([featureSets{ii,2} '(indicesToRemove,:) = [];']);
            end

            %% Data Split (Indices)
            trainIndices = ismember(rep,trainReps);
            testIndices = ismember(rep,testingReps);

            %% Subsample training data
            i = 1;
            for m = 1:numel(trainIndices)
                if mod(i,subSampleRate)
                    trainIndices(m) = 0;
                end
                i = i + 1;
            end

            %% Resample training data so rest has as many examples as the next most represented class
            trainCounts = histc(gesture(trainIndices),unique(gesture));
            maxGestureExamples = max(trainCounts(1:end-1)); % NOTE: unique still returns list in ascending order

            trainRestIndices = find(gesture == 53 & trainIndices == true);

            tempIndex = randperm(numel(trainRestIndices));
            indicesToRemove = trainRestIndices(tempIndex(maxGestureExamples+1:end));
            trainIndices(indicesToRemove) = 0;

            eval(['dataSet = ' featureSets{feature,2} ';']);

            %% Data Split Actual
            trainingData = dataSet(trainIndices,:);
            trainingClasses = gesture(trainIndices);

            testData = dataSet(testIndices,:);
            testClasses = gesture(testIndices);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %% KNN classifier
            classifierKNN = fitcknn(...
                trainingData, ...
                trainingClasses, ...
                'Distance', 'Euclidean', ...
                'Exponent', [], ...
                'NumNeighbors', knnNeighbours, ...
                'DistanceWeight', 'Equal', ...
                'Standardize', standardise);

            knnPredictions = predict(classifierKNN,testData);
            testClassesAll{subject,1} = testClasses;

            %% Pre-Amble %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            eval(['load s' num2str(subject) '_feat.mat']); % Load data
            eval(['load s' num2str(subject) '_rep.mat']); % Load relabelled repetitions
            eval(['load s' num2str(subject) '_gestureMajority.mat']); % Load gestures (majority)

            %% Remove gestures we're not using
            unUsedGestures = gestureOrder(subject,2,numGesturesToUse+1:end);
            indicesToRemove = ismember(gesture,unUsedGestures);

            gesture(indicesToRemove) = [];
            rep(indicesToRemove) = [];
            for ii=1:size(featureSets,1)
                eval([featureSets{ii,2} '(indicesToRemove,:) = [];']);
            end

            %% Data Split (Indices)
            trainIndices = ismember(rep,trainReps);
            testIndices = ismember(rep,testingReps);

            %% Subsample training data
            i = 1;
            for m = 1:numel(trainIndices)
                if mod(i,subSampleRate)
                    trainIndices(m) = 0;
                end
                i = i + 1;
            end

            %% Resample training data so rest has as many examples as the next most represented class
            trainCounts = histc(gesture(trainIndices),unique(gesture));
            maxGestureExamples = max(trainCounts(1:end-1)); % NOTE: unique still returns list in ascending order

            trainRestIndices = find(gesture == 53 & trainIndices == true);

            tempIndex = randperm(numel(trainRestIndices));
            indicesToRemove = trainRestIndices(tempIndex(maxGestureExamples+1:end));
            trainIndices(indicesToRemove) = 0;

            eval(['dataSet = ' featureSets{feature,2} ';']);

            %% Data Split Actual
            trainingData = dataSet(trainIndices,:);
            trainingClasses = gesture(trainIndices);

            testData = dataSet(testIndices,:);
            testClasses = gesture(testIndices);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %% LDA classifier
            classifierLDA = fitcdiscr(...
                trainingData, ...
                trainingClasses, ...
                'DiscrimType', 'pseudoLinear', ...
                'FillCoeffs', 'off', ...
                'SaveMemory', 'on');

            ldaPredictions = predict(classifierLDA,testData);
            testClassesAll{subject,2} = testClasses;

            %% Pre-Amble %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            eval(['load s' num2str(subject) '_feat.mat']); % Load data
            eval(['load s' num2str(subject) '_rep.mat']); % Load relabelled repetitions
            eval(['load s' num2str(subject) '_gestureMajority.mat']); % Load gestures (majority)

            %% Remove gestures we're not using
            unUsedGestures = gestureOrder(subject,3,numGesturesToUse+1:end);
            indicesToRemove = ismember(gesture,unUsedGestures);

            gesture(indicesToRemove) = [];
            rep(indicesToRemove) = [];
            for ii=1:size(featureSets,1)
                eval([featureSets{ii,2} '(indicesToRemove,:) = [];']);
            end

            %% Data Split (Indices)
            trainIndices = ismember(rep,trainReps);
            testIndices = ismember(rep,testingReps);

            %% Subsample training data
            i = 1;
            for m = 1:numel(trainIndices)
                if mod(i,subSampleRate)
                    trainIndices(m) = 0;
                end
                i = i + 1;
            end

            %% Resample training data so rest has as many examples as the next most represented class
            trainCounts = histc(gesture(trainIndices),unique(gesture));
            maxGestureExamples = max(trainCounts(1:end-1)); % NOTE: unique still returns list in ascending order

            trainRestIndices = find(gesture == 53 & trainIndices == true);

            tempIndex = randperm(numel(trainRestIndices));
            indicesToRemove = trainRestIndices(tempIndex(maxGestureExamples+1:end));
            trainIndices(indicesToRemove) = 0;

            eval(['dataSet = ' featureSets{feature,2} ';']);

            %% Data Split Actual
            trainingData = dataSet(trainIndices,:);
            trainingClasses = gesture(trainIndices);

            testData = dataSet(testIndices,:);
            testClasses = gesture(testIndices);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %% SVM classifier (rbf)
            templateRBFSVM = templateSVM(...
                'KernelFunction', 'rbf', ...
                'PolynomialOrder', [], ...
                'KernelScale', 'auto', ...
                'BoxConstraint', 1, ...
                'Standardize', standardise);

            classificationRBFSVM = fitcecoc(...
                trainingData, ...
                trainingClasses, ...
                'Learners', templateRBFSVM, ...
                'Coding', 'onevsall');

            rbfSVMPredictions = predict(classificationRBFSVM,testData);
            testClassesAll{subject,3} = testClasses;

            %% Pre-Amble %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            eval(['load s' num2str(subject) '_feat.mat']); % Load data
            eval(['load s' num2str(subject) '_rep.mat']); % Load relabelled repetitions
            eval(['load s' num2str(subject) '_gestureMajority.mat']); % Load gestures (majority)

            %% Remove gestures we're not using
            unUsedGestures = gestureOrder(subject,4,numGesturesToUse+1:end);
            indicesToRemove = ismember(gesture,unUsedGestures);

            gesture(indicesToRemove) = [];
            rep(indicesToRemove) = [];
            for ii=1:size(featureSets,1)
                eval([featureSets{ii,2} '(indicesToRemove,:) = [];']);
            end

            %% Data Split (Indices)
            trainIndices = ismember(rep,trainReps);
            testIndices = ismember(rep,testingReps);

            %% Subsample training data
            i = 1;
            for m = 1:numel(trainIndices)
                if mod(i,subSampleRate)
                    trainIndices(m) = 0;
                end
                i = i + 1;
            end

            %% Resample training data so rest has as many examples as the next most represented class
            trainCounts = histc(gesture(trainIndices),unique(gesture));
            maxGestureExamples = max(trainCounts(1:end-1)); % NOTE: unique still returns list in ascending order

            trainRestIndices = find(gesture == 53 & trainIndices == true);

            tempIndex = randperm(numel(trainRestIndices));
            indicesToRemove = trainRestIndices(tempIndex(maxGestureExamples+1:end));
            trainIndices(indicesToRemove) = 0;

            eval(['dataSet = ' featureSets{feature,2} ';']);

            %% Data Split Actual
            trainingData = dataSet(trainIndices,:);
            trainingClasses = gesture(trainIndices);

            testData = dataSet(testIndices,:);
            testClasses = gesture(testIndices);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %% SVM classifier (linear)
            templateLINSVM = templateSVM(...
                'KernelFunction', 'linear', ...
                'PolynomialOrder', [], ...
                'KernelScale', 'auto', ...
                'BoxConstraint', 1, ...
                'Standardize', standardise);

            classificationLINSVM = fitcecoc(...
                trainingData, ...
                trainingClasses, ...
                'Learners', templateLINSVM, ...
                'Coding', 'onevsone');

            linearSVMPredictions = predict(classificationLINSVM,testData);
            testClassesAll{subject,4} = testClasses;

            %% Pre-Amble %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            eval(['load s' num2str(subject) '_feat.mat']); % Load data
            eval(['load s' num2str(subject) '_rep.mat']); % Load relabelled repetitions
            eval(['load s' num2str(subject) '_gestureMajority.mat']); % Load gestures (majority)

            %% Remove gestures we're not using
            unUsedGestures = gestureOrder(subject,5,numGesturesToUse+1:end);
            indicesToRemove = ismember(gesture,unUsedGestures);

            gesture(indicesToRemove) = [];
            rep(indicesToRemove) = [];
            for ii=1:size(featureSets,1)
                eval([featureSets{ii,2} '(indicesToRemove,:) = [];']);
            end

            %% Data Split (Indices)
            trainIndices = ismember(rep,trainReps);
            testIndices = ismember(rep,testingReps);

            %% Subsample training data
            i = 1;
            for m = 1:numel(trainIndices)
                if mod(i,subSampleRate)
                    trainIndices(m) = 0;
                end
                i = i + 1;
            end

            %% Resample training data so rest has as many examples as the next most represented class
            trainCounts = histc(gesture(trainIndices),unique(gesture));
            maxGestureExamples = max(trainCounts(1:end-1)); % NOTE: unique still returns list in ascending order

            trainRestIndices = find(gesture == 53 & trainIndices == true);

            tempIndex = randperm(numel(trainRestIndices));
            indicesToRemove = trainRestIndices(tempIndex(maxGestureExamples+1:end));
            trainIndices(indicesToRemove) = 0;

            eval(['dataSet = ' featureSets{feature,2} ';']);

            %% Data Split Actual
            trainingData = dataSet(trainIndices,:);
            trainingClasses = gesture(trainIndices);

            testData = dataSet(testIndices,:);
            testClasses = gesture(testIndices);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %% Decision Tree Classifier
            classificationTree = fitctree(...
                trainingData, ...
                trainingClasses, ...
                'SplitCriterion', 'gdi', ...
                'MaxNumSplits', 150, ...
                'Surrogate', 'off');

            treePredictions = predict(classificationTree,testData);
            testClassesAll{subject,5} = testClasses;

            %% Save Stuff
            predictions{subject,feature,1} = knnPredictions;
            predictions{subject,feature,2} = ldaPredictions;
            predictions{subject,feature,3} = rbfSVMPredictions;
            predictions{subject,feature,4} = linearSVMPredictions;
            predictions{subject,feature,5} = treePredictions;

            %% Optionally save classifiers
            % classifiers{subject,feature,1} = classifierKNN;
            % classifiers{subject,feature,2} = classifierLDA;
            % classifiers{subject,feature,3} = classificationRBFSVM;
            % classifiers{subject,feature,4} = classificationLINSVM;
            % classifiers{subject,feature,5} = classificationTree;

            testClassesAll{subject} = testClasses;
        end

        trainTime = toc
        % save([savePath '\classifiers' featureSets{feature,1} gestureOrderPair{2} num2str(numGesturesToUse) '.mat'] ...
        %      ,'classifiers'); % Enable to save classifiers
        save([savePath '\predictions' featureSets{feature,1} gestureOrderPair{2} num2str(numGesturesToUse) '.mat'] ...
             ,'predictions','testClassesAll','trainTime');
    end
end