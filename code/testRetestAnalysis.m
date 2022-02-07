%% testRetestAnalysis
% This script loads a blink data set into a MATLAB table variable. When
% run, it will aggregate data for a given subject and parameter(s), split
% by session. It will then produce a plot which describes the within session
% correlation for each session and will calculate the test retest reliability
% between sessions.
%%

% load file path
dataPath = fileparts(fileparts(mfilename('fullpath')));
spreadsheet ='2_2022.csv';

% choose subject and parameters
subList = {15512, 15507, 15506, 15505, 14596, 14595, 14594, 14593, 14592, 14591};
varNamesToPlot = {'auc', 'latencyI', 'timeUnderI', 'openTimeI'};

xFit = linspace(log10(3),log10(70),50);
ylims = {[0 5e4], [30 80], [0 400], [50 400]};

figure();

% create MATLAB table variable
T = readtable(fullfile(dataPath,'data',spreadsheet));
allVarNames = T.Properties.VariableNames;

for vv = 1:length(varNamesToPlot)
    
    figure();
    plotNum = 0;
    pX = [];
    pY = [];
    oX = [];
    oY = [];
    
    for ss = 1:length(subList)

        % find scans for desired subject
        scans = T(ismember(T.subjectID,subList{ss}),:);
        scans = scans(ismember(scans.valid,'TRUE'),:);

        % separate scans into a table for each of the sessions
        dates = unique(scans.scanDate);
        sessOne = scans(ismember(scans.scanDate,dates(1,1)),:);
        sessTwo = scans(ismember(scans.scanDate,dates(2,1)),:);
        ii = find(strcmp(varNamesToPlot{vv},allVarNames));

        % session one data
        plotNum = plotNum + 1;
        y = sessOne.(allVarNames{ii});
        goodPoints = ~isnan(y);
        x = log10(sessOne.PSI);
        x = x(goodPoints);
        y = y(goodPoints);
        [x,idxX]=sort(x);
        y = y(idxX);

        % make plot
        subplot(2,length(subList),plotNum);
        plot(x,y,'ob');
        fitObj = fitlm(x,y,'RobustOpts', 'on');
        hold on
        plot(x,fitObj.Fitted,'-r')
        xlim(log10([2 100]));
        pX(end+1) = fitObj.Coefficients.Estimate(1);
        oX(end+1) = fitObj.Coefficients.Estimate(2);
        rsquare = fitObj.Rsquared.Ordinary;
        if rsquare > 1 || rsquare < 0
            rsquare = nan;
        end
        title([varNamesToPlot{vv} ' - session 1 - ' num2str(subList{ss}) sprintf(' R^2=%2.2f',rsquare)])
        xlabel('puff pressure [log psi]')
        ylim(ylims{vv});

        % session two data
        y = sessTwo.(allVarNames{ii});
        goodPoints = ~isnan(y);
        x = log10(sessTwo.PSI);
        x = x(goodPoints);
        y = y(goodPoints);
        [x,idxX]=sort(x);
        y = y(idxX);

        % make plot
        subplot(2,length(subList),plotNum + length(subList));
        plot(x,y,'ob');
        fitObj = fitlm(x,y,'RobustOpts', 'on');
        hold on
        plot(x,fitObj.Fitted,'-r')
        xlim(log10([2 100]));
        pY(end+1) = fitObj.Coefficients.Estimate(1);
        oY(end+1) = fitObj.Coefficients.Estimate(2);
        rsquare = fitObj.Rsquared.Ordinary;
        if rsquare > 1 || rsquare < 0
            rsquare = nan;
        end
        title([varNamesToPlot{vv} ' - session 2 - ' num2str(subList{ss}) sprintf(' R^2=%2.2f',rsquare)])
        xlabel('puff pressure [log psi]')
        ylim(ylims{vv});
    end
    
    % plot parameter test retest values across subjects
    figure();
    subplot(1,2,1);
    plot(pX,pY,'ob');
    fitObj = fitlm(pX,pY,'RobustOpts', 'on');
    hold on
    plot(pX,fitObj.Fitted,'-r')
    rsquare = fitObj.Rsquared.Ordinary;
    if rsquare > 1 || rsquare < 0
        rsquare = nan;
    end
    title([varNamesToPlot{vv} ' parameter - ' sprintf(' R^2=%2.2f',rsquare)])
    xlabel([varNamesToPlot{vv} ' parameter session 1'])
    ylabel([varNamesToPlot{vv} ' parameter session 2'])
    
    % plot offset test retest values across subjects
    subplot(1,2,2);
    plot(oX,oY,'ob');
    fitObj = fitlm(oX,oY,'RobustOpts', 'on');
    hold on
    plot(oX,fitObj.Fitted,'-r')
    rsquare = fitObj.Rsquared.Ordinary;
    if rsquare > 1 || rsquare < 0
        rsquare = nan;
    end
    title([varNamesToPlot{vv} ' offset - ' sprintf(' R^2=%2.2f',rsquare)])
    xlabel([varNamesToPlot{vv} ' offset session 1'])
    ylabel([varNamesToPlot{vv} ' offset session 2'])
    
end