%% Do windowing + feature extraction for NINAPRO database 1
%% Saves result to savePath
% Uses the raw extracted files for each subject of the 27 subjects in
% NINAPRO database 1, found at http://ninapro.hevs.ch/
% Saves 27 .mat files (one for each subject) in "savePath" that contain
% windowed feature data for the Mean Absolute Value (MAV) feature
% as well as 1-D arrays of which gesture and repetition is occuring at the
% most recent sample in each window
%
% Estimated run time: ~6min
% Adam Hartwell 2016

%% House Keeping/Setup
clear; clc; tic;

%% Settings
addpath('db1') % Database path: ***EDIT ACCORDIGNLY***
savePath = 'db1_feat'; % Save path: ***EDIT ACCORDIGNLY***

windowIncrement = 1; % Number of Samples
windowLength = 40; % Number of Samples

% Filter specs (cutoff and db sample rate)
fc = 5; % Hz
fs = 100; % Hz
[B,A] = butter(2,2*fc/fs,'low');

%% Loop through all the subjects
for subject = 1:27
    subject
    emgAll = [];
    restimulusAll = [];
    rerepetitionAll = [];

    % Dynamic allocation is sufficiently fast
    load(['S' num2str(subject) '_A1_E1.mat']);
    emgAll = [emgAll; emg];
    restimulusAll = [restimulusAll; restimulus];
    rerepetitionAll = [rerepetitionAll; rerepetition];

    load(['S' num2str(subject) '_A1_E2.mat']);
    emgAll = [emgAll; emg];
    restimulusAll = [restimulusAll; (restimulus+max(restimulusAll)*logical(restimulus))];
    rerepetitionAll = [rerepetitionAll; rerepetition];

    load(['S' num2str(subject) '_A1_E3.mat']);
    emgAll = [emgAll; emg];
    restimulusAll = [restimulusAll; (restimulus+max(restimulusAll)*logical(restimulus))];
    rerepetitionAll = [rerepetitionAll; rerepetition];

    numChannels = size(emgAll,2);

    %% Preprocess with filter
    for k=1:numChannels
        emgAll(:,k) = filtfilt(B, A, emgAll(:,k));
    end

    %% Windowing
    numWindows = floor((size(emgAll,1)- windowLength)/windowIncrement) + 1;

    windows = zeros(numWindows,windowLength,numChannels);
    gesture = zeros(numWindows,1);
    rep = zeros(numWindows,1);

    classList = unique(restimulusAll);
    repList = unique(rerepetitionAll);

    winStart = 1;
    winEnd = winStart+windowLength-1;
    for n = 1:numWindows
        windows(n,:,:) = emgAll(winStart:winEnd,:); % Window EMG data

        rep(n) = rerepetitionAll(winEnd);
        gesture(n) = restimulusAll(winEnd);

        winStart = winStart + windowIncrement;
        winEnd = winEnd + windowIncrement;
    end

    %% Feature Extraction
    emgMAV = zeros(numWindows,numChannels);

    for n = 1:numWindows
        % Mean Absolute Value
        emgMAV(n,:) = mean(windows(n,:,:));
    end

    %% Save Data
    save([savePath '\s' num2str(subject) '_feat'],'gesture','rep','emgMAV');
end
toc
