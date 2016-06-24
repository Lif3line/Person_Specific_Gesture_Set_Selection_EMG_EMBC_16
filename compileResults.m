%% Compile results into .mat file for easy reference later
% Need to have run all 4 trainClassifiersX scripts
% Adam Hartwell 2016

addpath('results') % ***EDIT ACCORDIGNLY***

classifierSet = {
                 'knn';
                 'lda';
                 'svm rbf';
                 'svm linear';
                 'tree'
                 };

fileNames = {'predictionsMAVArbitary';
             'predictionsMAVSuperset';
             'predictionsMAVKL';
             'predictionsMAVMean'
             };


resultsToCompile = 2:53; % Which results to compile (number of gestures in set)
resultLen = numel(resultsToCompile);

resultsArb = zeros(5,resultLen);
for classifier = 1:numel(classifierSet)
    for numGestures = resultsToCompile
        eval(['load ' fileNames{1} num2str(numGestures)]);

        classMean = getClassifierAccuracy(predictions(:,1,classifier),testClassesAll);
        disp(['Gestures: ' num2str(numGestures) ' ' classifierSet{classifier} ' Mean:' num2str(classMean)]);
        resultsArb(classifier,numGestures-1) = classMean;
    end
end

resultsSuper = zeros(5,resultLen);
for classifier = 1:numel(classifierSet)
    for numGestures = resultsToCompile
        eval(['load ' fileNames{2} num2str(numGestures)]);

        testClassesTmp = testClassesAll(:,classifier);

        classMean = getClassifierAccuracy(predictions(:,1,classifier),testClassesTmp);
        disp(['Gestures: ' num2str(numGestures) ' ' classifierSet{classifier} ' Mean:' num2str(classMean)]);
        resultsSuper(classifier,numGestures-1) = classMean;
    end
end

resultsKL = zeros(5,resultLen);
for classifier = 1:numel(classifierSet)
    for numGestures = resultsToCompile
        eval(['load ' fileNames{3} num2str(numGestures)]);

        classMean = getClassifierAccuracy(predictions(:,1,classifier),testClassesAll);
        disp(['Gestures: ' num2str(numGestures) ' ' classifierSet{classifier} ' Mean:' num2str(classMean)]);
        resultsKL(classifier,numGestures-1) = classMean;
    end
end

resultsMean = zeros(5,resultLen);
for classifier = 1:numel(classifierSet)
    for numGestures = resultsToCompile
        eval(['load ' fileNames{4} num2str(numGestures)]);

        classMean = getClassifierAccuracy(predictions(:,1,classifier),testClassesAll);
        disp(['Gestures: ' num2str(numGestures) ' ' classifierSet{classifier} ' Mean:' num2str(classMean)]);
        resultsMean(classifier,numGestures-1) = classMean;
    end
end

save results.mat resultsMean resultsKL resultsSuper resultsArb