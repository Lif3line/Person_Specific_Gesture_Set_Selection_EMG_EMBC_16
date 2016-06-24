function [meanAcc, rawAvgAccs] = getClassifierAccuracy(predictionsAll,testClassesAll)
% Take in predictions and actual values for test classes, calculate average
% accuracy per subject and also return the mean accuracy across all
% subjects

    rawAvgAccs = zeros(size(testClassesAll,1),1);
	for ii = 1:size(testClassesAll,1) % Loop each subject (row)
        predictions = predictionsAll{ii};
        testClasses = testClassesAll{ii};

        usedClasses = unique(testClasses);
        testCounts = histc(testClasses,usedClasses);
        totalTestPoints = sum(testCounts);

        %% Accuracy Calculation (for 1 subject)
        classScore = zeros(53,1);
        for n=1:totalTestPoints
            if predictions(n) == testClasses(n);
                classScore(predictions(n)) = classScore(predictions(n)) + 1;
            end
        end

        curAvgAcc = classScore(usedClasses)./testCounts; % Get the average accuracy

        rawAvgAccs(ii) = mean(curAvgAcc);
	end

    meanAcc = mean(rawAvgAccs);
end
