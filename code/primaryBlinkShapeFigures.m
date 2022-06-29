%% primaryBlinkShapeFigures
% Run after primaryBlinkShapeAnalysis.m

% Define a gray-to-red color set for puff-pressure
psiColors = [0.5:0.125:1.0; 0.5:-0.125:0; 0.5:-0.125:0]';


%% Acquisition order and example raw set of blinks
psiAcqOrder = [4 4 1 3 5 5 3 1 2 4 2 2 1 5 4 3 3 4 5 2 3 2 5 1 1 4];
figure
set(gcf, 'Position',  [100, 100, 400, 200])
subplot(3,2,1:2)
plotIdx = 1;
dash = 10;
dot = 2;
for aa=1:length(psiAcqOrder)
    plot( plotIdx:plotIdx+dash-1, repmat(psiAcqOrder(aa),dash,1), '-', 'Color', psiColors(psiAcqOrder(aa),:),'LineWidth',4)
    if aa==1; hold on; end
    plotIdx = plotIdx+dash+dot;
end
xlim([1 plotIdx])
axis off

subplot(3,2,3:4)
subjectID = 14594;
[~,~,~,blinkVectorRaw] = returnBlinkTimeSeries( subjectID, [], 1 );
spacing = 10;
plotIdx = (nTimePoints)*nBlinksPerAcq;
blinkIdx = 1;
for aa=2:length(psiAcqOrder)
    for bb = 1:nBlinksPerAcq
        plot( plotIdx:plotIdx+nTimePoints-1, blinkVectorRaw(blinkIdx,:), '-', 'Color', psiColors(psiAcqOrder(aa),:))
        if aa==2 && bb==1; hold on; end
        plotIdx = plotIdx + nTimePoints;
        blinkIdx = blinkIdx+1;
    end
end
plot([0 0],[0 -250],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
t=text(-600,-250,'250 pixels');
t.Rotation = 90;
plot([0 1000],[-250 -250],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
t=text(0,-150,'1s');
xlim([1 plotIdx])
axis off
title(num2str(subjectID));

for ss=1:2
    subplot(3,2,ss+4)
    for pp=1:nPSIs
        plot(temporalSupport, returnBlinkTimeSeries( subjectID, targetPSISet(pp), ss ), '-', 'Color', psiColors(pp,:),'LineWidth',1.5);
        if pp==1;hold on; end
    end
    axis off
    plot([0 0],[-125 25],'-b')
    title(sprintf('Session %d',ss));
    if ss==1
        plot([-100 -100],[0 -100],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
        plot([-100 0],[-125 -125],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
        t=text(-100,-50,'100 msec');
        t=text(-175,-100,'100 pixels');
        t.Rotation = 90;
    end
end
saveas(gcf,fullfile(plotSaveDir,'acquisitionOrder.pdf'));


%% Average blink response by puff pressure
figure
tmpX = squeeze(mean(X,1));
tmpXfit = squeeze(mean(Xfit,1));
for pp = 1:nPSIs
    plot(temporalSupport,tmpX(pp,:),'-','Color',psiColors(pp,:),'LineWidth',1.5)
    hold on
    plot(temporalSupport,tmpXfit(pp,:),'--','Color',psiColors(pp,:),'LineWidth',1.5)
end
plot([0 0],[-125 25],'-b')
plot([-100 -100],[0 -100],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
plot([-100 0],[-125 -125],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
axis off
xlabel('time [msecs]');
ylabel('blink depth [pixels]');
saveas(gcf,fullfile(plotSaveDir,'averageBlnkResponseByPSI.pdf'));


%% Illustration of the ICA components
figure
componentNames = {'amplitude','shape1','shape2','speed'};
componentColors = [0 0 0; 0.65 0.65 0.65; 0.85 0.85 0.85; 0 0 1];
componentWidths = [1.5, 1, 1, 1.5];
plotOrder = [1 4 2 3];
for cc = plotOrder
    plot(temporalSupport,components(:,cc),'-','Color',componentColors(cc,:),'LineWidth',componentWidths(cc))
    hold on
end
legend(componentNames(plotOrder))
xlabel('time [msecs]');
ylabel('component value [a.u.]');
saveas(gcf,fullfile(plotSaveDir,'ICAcomponents.pdf'));

% Report the correlation between the first derivative of the first
% component and the fourth component.
fprintf('correlation of component 1 with mean blink is r = %2.2f \n',corr( components(:,1),mean(X_ICA)' ) );
fprintf('correlation of first derivative of component 1 with component 4 is r = %2.2f \n',corr([0; diff(components(:,1))],components(:,4)) );


%% Plot of the coefficients by puff pressure
figure
meanCoeff = squeeze(mean(Xcoeff,1));
semCoeff = squeeze(std(Xcoeff,1))./sqrt(nSubs);
plotOrder = [1 3 4 2];
for cc=1:4
    subplot(2,2,plotOrder(cc))
    for pp = 1:nPSIs
        plot([log10(targetPSISet(pp)) log10(targetPSISet(pp))],[meanCoeff(pp,cc)+2.*semCoeff(:,cc),meanCoeff(pp,cc)-2.*semCoeff(:,cc)],'-k');
        hold on
        plot(log10(targetPSISet(pp)),meanCoeff(pp,cc),'o',...
            'MarkerFaceColor',componentColors(cc,:),'MarkerEdgeColor','none' );
    end
    % Add a linear fit line
    if cc==4
        pp = polyfit(xVals(2:end),meanCoeff(2:end,cc),1);
        plot([xVals(2)+xValMid xVals(end)+xValMid],polyval(pp,[xVals(2) xVals(end)]),'-r')
        plot([xVals(1)+xValMid xVals(2)+xValMid],polyval(pp,[xVals(2) xVals(2)]),'-r')
        text(1,100,'±2SEM');
    else
        pp = polyfit(xVals,meanCoeff(:,cc),1);
        plot([xVals(1)+xValMid xVals(end)+xValMid],polyval(pp,[xVals(1) xVals(end)]),'-r')
    end
    xticks(log10(targetPSISet));
    xticklabels(arrayfun(@num2str, targetPSISet, 'UniformOutput', 0));
    xlabel('stimulus intensity [log PSI]')
    title(componentNames{cc})
    box off
end
saveas(gcf,fullfile(plotSaveDir,'coefficientsByPSI.pdf'));


%% Calculate the correlation of the fit with each average blink response
for ss=1:nSubs
    for pp=1:5
        varExplained(ss,pp) = corr(squeeze(X(ss,pp,:)),squeeze(Xfit(ss,pp,:)))^2';
    end
end
fprintf('The mean [range] of R^2 of model fit to blink is %2.2f [%2.2f - %2.2f]\n',mean(varExplained(:)),min(varExplained(:)),max(varExplained(:)))


%% Show scatter plots of across-session amplitude and speed
limVals = {...
    [0 700],[-100 300];...
    [0 1000],[-150 150]};
subIdxToShow = {[8,13],[16,9]}; % [14, 13]
nameRow = {'slope','offset'};
axisLabels = {'amplitude','velocity'};
figure
subjectLineStyle = {'-',':'};

for rr=1:2
    subplot(2,3,(2-rr)*3+1);
    vals1 = ampPuffCoeff(:,rr);
    vals2 = speedPuffCoeff(:,rr);
    scatter(vals1,vals2,'MarkerFaceColor',[0.25 0.25 0.25],'MarkerEdgeColor','none','MarkerFaceAlpha',0.5);
    xlim(limVals{rr,1}); ylim(limVals{rr,2});
    xlabel([axisLabels{1} ' ' nameRow{rr} ' [a.u.]']);
    ylabel([axisLabels{2} ' ' nameRow{rr} ' [a.u.]']);
    axis square; box off
    titleStr = nameRow{rr};
    title(titleStr);
    hold on
    for ss=1:length(subIdxToShow{rr})
        dims = [range(xlim)/10, range(ylim)/10];
        pos = [vals1(subIdxToShow{rr}(ss))-dims(1)/2,vals2(subIdxToShow{rr}(ss))-dims(2)/2,dims(1),dims(2)];
        rectangle('Position',pos,'Curvature',[1,1],'LineStyle',subjectLineStyle{ss},'EdgeColor','r')
    end
    if rr==2
        pressureToPlotIdx = [0 0 1 0 0];
    else
        pressureToPlotIdx = [1 1 1 1 1];
    end
    for ss=1:length(subIdxToShow{rr})
        subplot(2,3,(2-rr)*3+1+ss);
        for pp=1:length(pressureToPlotIdx)
            if pressureToPlotIdx(pp)==1
                plot(temporalSupport, returnBlinkTimeSeries( subjectIDs{subIdxToShow{rr}(ss)}, targetPSISet(pp) ), subjectLineStyle{ss}, 'Color', psiColors(pp,:),'LineWidth',1);
                hold on
            end
        end
        ylim([-150 25]);
        plot([-100 -100],[0 -100],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
        plot([-100 0],[-125 -125],'-','Color',[0.5 0.5 0.5],'LineWidth',2)
        axis off
    end
end
saveas(gcf,fullfile(plotSaveDir,'subjectCoeffDistribution.pdf'));


%% Show scatter plots of test / retest of overall amplitude and speed
limVals = {...
    [0 800],[-100 300];...
    [0 1000],[-200 200]};
symbolColors={'k','b'};
nameRow = {'slope','offset'};
axisLabels = {'amplitude','velocity'};
figure
for cc=1:2
    for rr=1:2
        subplot(2,2,(2-rr)*2+cc);
        if cc==1
            vals1 = ampPuffCoeff1(:,rr);
            vals2 = ampPuffCoeff2(:,rr);
        else
            vals1 = speedPuffCoeff1(:,rr);
            vals2 = speedPuffCoeff2(:,rr);
        end
        scatter(vals1,vals2,'MarkerFaceColor',symbolColors{cc},'MarkerEdgeColor','none','MarkerFaceAlpha',0.5);
        xlim(limVals{rr,cc}); ylim(limVals{rr,cc});
        titleStr = sprintf([axisLabels{cc} ' ' nameRow{rr} ' r=%2.2f'],corr(vals1,vals2));
        title(titleStr);
        axis square; box off
        xlabel([axisLabels{cc} ' ' nameRow{rr} ' [a.u.]']);
        ylabel([axisLabels{cc} ' ' nameRow{rr} ' [a.u.]']);
        a=gca;
        a.YTick = a.XTick;
        a.YTickLabel = a.XTickLabel;
        refline(1,0);
    end
end
saveas(gcf,fullfile(plotSaveDir,'testRetestCoefficients.pdf'));


%% Illustration of all blink responses and ICA model fit
betweenSubGap = 1;
grayScaleRangePixels = [50 -200];

% Loop over the three display panels
for xx = 1:3
    figure
    switch xx
        case 1
            % Create uniC, which is permuted to order rows by subject then puff
            uniC = reshape(permute(X,[2 1 3]),nSubs*nPSIs,nTimePoints);
            titleStr = 'average blinks';
            C = ones(85+(betweenSubGap*16),161+10,3);
        case 2
            uniC = reshape(permute(Xfit,[2 1 3]),nSubs*nPSIs,nTimePoints);
            titleStr = 'model fit';
            C = ones(85+(betweenSubGap*16),161+10,3);
        case 3
            uniC = reshape(permute(X-Xfit,[2 1 3]),nSubs*nPSIs,nTimePoints);
            titleStr = 'residuals';
            C = ones(85+(betweenSubGap*16),161+10,3);
    end

    % Map uniC to the 0-1 range. We store the scaling factors to use them
    % for all three matrix displays.
    uniC(uniC>grayScaleRangePixels(1))=grayScaleRangePixels(1);
    uniC(uniC<grayScaleRangePixels(2))=grayScaleRangePixels(2);
    uniC = (uniC-grayScaleRangePixels(1));
    uniC = 1-(uniC ./ sum(grayScaleRangePixels));
    if xx==1
        grayAtZeroPixels = mean(mean(uniC(:,1:zeroIdx)));
    end

    for ss=1:17
        XrowStart = (ss-1)*nPSIs+1;
        CrowStart = (ss-1)*(nPSIs+betweenSubGap)+1;

        % Place the blink vectors into the matrix
        C(CrowStart:CrowStart+nPSIs-1,11:end,:) = repmat(uniC(XrowStart:XrowStart+4,:),1,1,3);

        % Add a color bar
        C(CrowStart:CrowStart+nPSIs-1,1:7,:) = permute(repmat(psiColors,1,1,7),[1 3 2]);

        % Add a marker for stimulus onset
        C(CrowStart:CrowStart+nPSIs-1,10+zeroIdx,:) = repmat([0 0 1],nPSIs,1);

    end

    image(imresize(C,[size(C,1)*4,size(C,2)],"nearest")); axis off
    axis equal
    exportgraphics(gca,fullfile(plotSaveDir,sprintf('blinkAndFitAllSubjects_%d.png',xx)));
end


%% Supplementary figure: Reconstruction error with fewer components

% Calculate the variance explained as a function of dimensionality
figure
for qq=1:6
    subplot(3,3,qq)
    tmpMdl = rica(X_ICA,qq);
    tmpFit = (tmpMdl.TransformWeights*tmpMdl.transform(X_ICA)')';
    tmpFitX = reshape(tmpFit,nSubs,nPSIs,nTimePoints);
    tmpXfit = squeeze(mean(tmpFitX,1));
    rSquaredByDimension = corr(X_ICA(:),tmpFit(:))^2;
    tmpX = squeeze(mean(X,1));
    for pp = 1:nPSIs
        plot(temporalSupport,tmpX(pp,:),'-','Color',psiColors(pp,:),'LineWidth',0.5)
        hold on
        plot(temporalSupport,tmpXfit(pp,:),'--','Color',psiColors(pp,:),'LineWidth',1)
    end
    xlabel('time [msecs]');
    ylabel('blink depth [pixels]');
    title(sprintf('q=%d, R^2=%2.2f',qq,rSquaredByDimension))
end
saveas(gcf,fullfile(plotSaveDir,'Supp_variationInICAq.pdf'));