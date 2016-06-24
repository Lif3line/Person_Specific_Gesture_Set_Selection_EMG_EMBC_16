%% Convert gesture array into new forms saving to savePath
% Change rest id to 53 from 0 for consistency
% Save as two new arrays;
% * First with movement id based on latest sample in window
% * Second with majority vote for movement id
% Better to get during the feature extraction process if the window
% increment wassn't 1 as here
% Require features to have been extracted with extractFeatures.m
%
% Estimated run time: ~8min
% Adam Hartwell 2016

%% House Keeping/Setup
clear; clc; tic;

addpath('db1_feat') % Database feature path: ***EDIT ACCORDIGNLY***
savePath = 'gesture'; % Save path: ***EDIT ACCORDIGNLY***

windowLength = 40;

for subject=1:27
    subject
    eval(['load s' num2str(subject) '_feat.mat']);

    orgGesture = gesture;

    gesture(gesture == 0) = 53; % For consistency with paper

    % Save latest sample array
    eval(['save ' savePath '\s' num2str(subject) '_gestureLatest.mat gesture']);

    tmp = zeros(numel(gesture),1);
    tmp(1:windowLength-1) = 53; % Known that data begins with rest (inspection)
    for ii=windowLength:numel(gesture) %
        startPos = ii - windowLength + 1;
        tmp(ii) = mode(orgGesture(startPos:ii));
    end

    gesture = tmp;
    gesture(gesture == 0) = 53; % For consistency with paper

    % Save majority vote array
    eval(['save ' savePath '\s' num2str(subject) '_gestureMajority.mat gesture']);
end
toc
