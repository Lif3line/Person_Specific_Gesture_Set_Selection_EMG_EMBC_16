%% Calculate optimal gesture selection orders for mean distance and KL
%% divergence also output arbitary order, saving to savePath
% Returns a subjects*gestures array indicating the optimal order ro
% add gestures to a subset for classification for each subject
% Superset requires extraction from a classification run on all 53 movements
% An example of same is included with these files
% Requires features to have been extracted with extractFeatures.m
% Requires gesture array to be updated by extractGesture.m
%
% Adam Hartwell 2016

%% House Keeping/Setup
clear; clc; tic;

%% Settings
addpath('db1_feat') % Database feature path: ***EDIT ACCORDIGNLY***
addpath('gesture') % Gesture array path: ***EDIT ACCORDIGNLY***
savePath = 'gestureOrders'; % Save path: ***EDIT ACCORDIGNLY***

feature = {'MAV' 'emgMAV'}; % Feature name-array_name pair - could be altered for other features

%% Variables
numGestures = 53;
numSubjects = 27;
gestureOrderMean = zeros(numSubjects,numGestures);
gestureOrderKLDivergence = zeros(numSubjects,numGestures);
gestureOrderSuperset = zeros(numSubjects,numGestures);

%% Arbitary order
gestureOrderArb = repmat([53 1:52],numSubjects,1);

gestureOrder = gestureOrderArb;
save([savePath '\gestureOrderArbitary' feature{1}],'gestureOrder');

%% Other orders
for subject = 1:numSubjects
    eval(['load s' num2str(subject) '_feat.mat']); % Load data
    eval(['load s' num2str(subject) '_gestureMajority.mat']); % Load gestures (majority)

    eval(['dataSet = ' feature{2} ';']);

    %% Mean distance order
    % Get means
    meanData = zeros(numGestures,size(dataSet,2));
    for ii = 1:numGestures
        meanData(ii,:) = mean(dataSet(gesture == ii,:));
    end

    gestureSetMean = [53]; % For the purposes of the paper we take the rest movement as a base

    while numel(gestureSetMean) < numGestures
        pythagorianDistances = zeros(numel(gestureSetMean),numGestures);
        for ii = 1:numel(gestureSetMean)
            relativeDistances = meanData - repmat(meanData(gestureSetMean(ii),:),[numGestures 1]);

            pythagorianDistances(ii,:) = sqrt(sum((relativeDistances.^2),2));
            pythagorianDistances(ii,gestureSetMean) = NaN; % Remove distances from current set
        end

        [~,idx] = max(min(pythagorianDistances,[],1),[],2);

        gestureSetMean = [gestureSetMean idx];
    end

    gestureOrderMean(subject,:) = gestureSetMean;

    %% KL divergence order
    % Get variances
    covData = cell(numGestures,1);
    for gestureNum = 1:numGestures
        covData{gestureNum} = cov(dataSet(gesture == gestureNum,:));
    end

    k = size(dataSet,2);

    gestureSetKL = [53]; % For the purposes of the paper we take the rest movement as a base

    while numel(gestureSetKL) < numGestures
        divergences = zeros(numel(gestureSetKL),numGestures);
        for ii = 1:numel(gestureSetKL)
            for jj = 1:numGestures
                mu1 = meanData(gestureSetKL(ii),:)';
                mu2 = meanData(jj,:)';
                cov1 = covData{gestureSetKL(ii)};
                cov2 = covData{jj};

                KLpq = 0.5*(trace(cov1\cov2)+(mu1-mu2)'*inv(cov1)*(mu1-mu2) - k + log(det(cov1)/det(cov2)));
                KLqp = 0.5*(trace(cov2\cov1)+(mu2-mu1)'*inv(cov2)*(mu2-mu1) - k + log(det(cov2)/det(cov1)));
                divergences(ii,jj) = KLpq + KLqp; % Symmetric divergence
            end
        end

        for ii = 1:numel(gestureSetKL)
            divergences(:,gestureSetKL(ii)) = NaN;
        end

        [~,idx] = max(min(divergences,[],1),[],2);

        gestureSetKL = [gestureSetKL idx];
    end

    gestureOrderKLDivergence(subject,:) = gestureSetKL;

end

gestureOrder = gestureOrderMean;
save([savePath '\gestureOrderMean' feature{1}],'gestureOrder');

gestureOrder = gestureOrderKLDivergence;
save([savePath '\gestureOrderKLDivergence' feature{1}],'gestureOrder');

toc