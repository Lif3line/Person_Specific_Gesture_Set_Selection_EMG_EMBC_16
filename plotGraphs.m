%% Plot results
% Takes results.m file produced by compileResults.m and produces a pretty
% graph
% Adam Hartwell 2016

%% Housekeeping
clear; clc;

load results

% Next 3 need to be kept coherent
resultNames = {
                'resultsMean';
                'resultsKL';
                'resultsSuper';
                'resultsArb'
                };

xNames = {
            'xMean';
            'xKL';
            'xClass';
            'xArb'
            };

legendEntries = {
                    'Mean Distance';
                    'KL Divergence';
                    'Superset Performance';
                    'Arbitary'
                    };

titles = {
         {'KNN'; 'Average Percentage Correctly Classified Points'};
         {'LDA'; 'Average Percentage Correctly Classified Points'};
         {'SVM Radial Basis Function' ; 'Average Percentage Correctly Classified Points'};
         {'SVM Linear'; 'Average Percentage Correctly Classified Points'};
         {'Decision Tree' 'Average Percentage Correctly Classified Points'}
         };

figure(1); clf reset
for classifier = 1:size(titles)
    for metric = 1:size(resultNames)
        subplot(5,1,classifier)
        hold on;

        eval(['plot(2:53,' resultNames{metric} '(classifier,:),''linewidth'',2)']);

        title(titles{classifier})
        ylim([0 1])
        xlim([2 53])

        ylabel('Performance');
        xlabel('Number of Movements');

        grid on;
        grid minor;
        hold off;
    end
end

legend(legendEntries{1},legendEntries{2},legendEntries{3},legendEntries{4}, ...
    'position', 'southoutside','Orientation','horizontal')


