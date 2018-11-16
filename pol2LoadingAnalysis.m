allColors = [0.9412    0.2353    0.2353;...
    0.9412    0.6118    0.2353;...
    0.9412    0.8941    0.2353;...
    0.5176    0.9412    0.2353;...
    0.2353    0.9412    0.3765;...
    0.2353    0.8941    0.9412;...
    0.2353    0.6588    0.9412;...
    0.2353    0.3294    0.9412;...
    0.3765    0.2353    0.9412;...
    0.5647    0.2353    0.9412;...
    0.7529    0.2353    0.9412;...
    0.9412    0.2353    0.8941;...
    1.0000    0.4392    0.8118;...
    0.9412    0.2353    0.6118;...
    1.0000    0.5804    0.5804;...
    1.0000    0.8314    0.5804;...
    0.8863    1.0000    0.5804;...
    0.5804    1.0000    0.6902;...
    0.5804    1.0000    0.9451;...
    0.5804    0.8863    1.0000];

close all
dataSet = 'mcp_opt';%'p2p_4f_opt';
data = LoadMS2Sets(dataSet);

% Checking to see which data sets has fittedLineEquations
% the data set will not be plotted if it does not have this variables 
% and associated fields!
dataSetsToInclude = [];
for currentDataSet = 1:length(data)
    if isfield(data(currentDataSet),'fittedLineEquations')
        dataSetsToInclude = [dataSetsToInclude currentDataSet];
    end
end

%% Initializing and positioning figures
% figure for scatter of loading rate vs AP
scatterLoading = figure();
set(scatterLoading,'Position',[4.5000 43.5000 679 601])

% figure for box and whisker of loading rate vs AP
boxLoading = figure();
set(boxLoading,'Position',[693 43.5000 585.5000 215])

% figure for avg loading rate vs AP
avgLoading = figure();
set(avgLoading,'Position',[692 341 583 303.5000])

% figure for time on vs AP
% scatterTimeOn = figure();

% figure for avg time on vs AP
avgTimeOn = figure();
set(avgTimeOn,'Position',[691.5000 43.5000 583 303.5000])


%% plotting with continous AP axis
colorsUsed = {};
meansOfSets = [];
plotsLabeledLoading = plot(NaN,NaN);
plotsLabeledTimeOn = plot(NaN,NaN);
namesLoading = {'placeHolder'};
namesTimeOn = {'placeHolder'};
allAPPositions = [];
allInitialSlopes = [];
allSlopeError = []; % the error is taken to be the norm of the residuals
allTimeOn = [];

for currentDataSet = dataSetsToInclude
    numberOfParticles = length(data(currentDataSet).Particles);
    labelPlot = 0; %condition 
    clear apPositions
    currentInitialSlopes = NaN(1,numberOfParticles);
    currentTimeOn = NaN(1,numberOfParticles);
    errorEstimations = NaN(1,numberOfParticles);
    for currentParticle = 1:numberOfParticles
        apPositions(currentParticle) = mean(data(currentDataSet).Particles(currentParticle).APpos);
        try
            tempSlope = ...
                data(currentDataSet).fittedLineEquations(currentParticle).Coefficients(1,1);
            tempTimeOn = roots(data(currentDataSet).fittedLineEquations(currentParticle).Coefficients(1,:));
            disp([num2str(currentDataSet) ', ' num2str(currentParticle) ': ' ...
                num2str(tempTimeOn)])
            if tempSlope >= 0
                currentInitialSlopes(currentParticle) = tempSlope;
                errorEstimations(currentParticle) =...
                    data(currentDataSet).fittedLineEquations(currentParticle).ErrorEstimation(1).normr/...
                    data(currentDataSet).fittedLineEquations(currentParticle).numberOfParticlesUsedForFit(1);
                currentTimeOn(currentParticle) = tempTimeOn;
            end
        end
    end
    
    %Storing these values
    allAPPositions(end+1:end+numberOfParticles) = apPositions;
    allInitialSlopes(end+1:end+numberOfParticles) = currentInitialSlopes;
    allSlopeError(end+1:end+numberOfParticles) = errorEstimations;
    allTimeOn(end+1:end+numberOfParticles) = currentTimeOn;
    
    %Plotting loading rate vs AP -----------------------------------------
    %Plotting the error bars
    figure(scatterLoading)
    hold on
    errorbar(apPositions, currentInitialSlopes,errorEstimations,'.',...
        'Color','black');%allColors(currentDataSet,:));
    %Plotting the values 
    plotsLabeledLoading(end+1) = plot(apPositions,currentInitialSlopes,'.','MarkerSize',15,...
        'Color',allColors(currentDataSet,:));

    if sum(isnan(currentInitialSlopes)) ~= length(data(currentDataSet).Particles)
        hold on 
        meanInitialSlope = nanmean(currentInitialSlopes);
        
        apBinOfMovie = data(currentDataSet).APbinID(max(data(currentDataSet).TotalEllipsesAP,[],2)>0);
        startX = min(apBinOfMovie);
        endX = max(apBinOfMovie);
        lengthX = endX-startX;
        
        rectanglePosition = [ startX meanInitialSlope*0.99 ...
            lengthX meanInitialSlope*0.01];
        rectangle('Position',rectanglePosition,'Curvature',0.2,...
            'FaceColor',allColors(currentDataSet,:),...
            'EdgeColor',allColors(currentDataSet,:));
        
%         plotsLabeled(end+1) = plot(nanmean(apPositions), nanmean(currentInitialSlopes),...
%             '.','MarkerSize',30,'Color',allColors(currentDataSet,:));%h.Color);
        
        nameTemp = regexp(data(currentDataSet).Prefix,'\d*','Match');
        namesLoading{end+1} = nameTemp{end};
        disp(nameTemp{end})
    end
    hold off 
    
    % Plotting time on vs AP ----------------------------------------------
%     figure(scatterTimeOn)
%     hold on 
    
end
% for loading rate vs AP --------------------------------------------------
figure(scatterLoading)
legend([plotsLabeledLoading(2:end)],{namesLoading{2:end}}, 'Interpreter', 'none');
xlim([0 1])
xlabel('Embryo Length (%)')
ylabel('Initial Rate (a.u./minute)')
set(gca,'YScale','log')

% for time on vs AP -------------------------------------------------------
% figure(scatterTimeOn)
% legend([plotsLabeledLoading(2:end)],{namesLoading{2:end}}, 'Interpreter', 'none');
% xlim([0 1])
% xlabel('Embryo Length (%)')
% ylabel('Initial Rate (a.u./minute)')
% set(gca,'YScale','log')

%% plotting with binned ap
ap = data(1).APbinID;
apBinWidth = ap(2)-ap(1);
apMid = ap+apBinWidth/2;
apMidString = cellstr(string(ap+apBinWidth/2));
numAPBins = length(ap);
meanInitialRateAP = NaN(1,numAPBins);
seInitialRateAP = NaN(1,numAPBins);
meanTimeOnAP = NaN(1,numAPBins);
apBinGrouping = NaN(1,length(allInitialSlopes)); % stores corresponding bin string for allInitialSlopes

% binPlots = plot(NaN,NaN);
% binNames = {'placeholder'};
for currentAPBinIndex = 2:numAPBins % index of upper bound of ap
    lowerBound = ap(currentAPBinIndex-1);
    upperBound = ap(currentAPBinIndex);
    pointsIncluded = (allAPPositions>lowerBound) & (allAPPositions<upperBound);
    apBinGrouping(pointsIncluded) = round(mean([lowerBound,upperBound]),2,'significant');
    
    meanInitialRateAP(currentAPBinIndex-1) = nanmean(allInitialSlopes(pointsIncluded));
    denomLoading = sqrt(sum(~isnan((allInitialSlopes(pointsIncluded)))));
    
    meanTimeOnAP(currentAPBinIndex-1) = nanmean(allTimeOn(pointsIncluded));
    denomTimeOn = sqrt(sum(~isnan((allTimeOn(pointsIncluded)))));
    
    if ~denomLoading
        denomLoading = 1;
    end
    seInitialRateAP(currentAPBinIndex-1) = nanstd(allInitialSlopes(pointsIncluded))/denomLoading;
  
    if ~denomTimeOn 
        denomTimeON = 1;
    end
    seTimeOnAP(currentAPBinIndex-1) = nanstd(allInitialSlopes(pointsIncluded))/denomTimeON;
    
    %     if sum(pointsIncluded)
%         binPlots(end+1) = plot(allAPPositions(pointsIncluded),...
%             allInitialSlopes(pointsIncluded),'.','MarkerSize',10);
%     end
end

figure(boxLoading)
boxplot(allInitialSlopes,apBinGrouping,'PlotStyle','Compact')

figure(avgLoading)
hold on 
% % bar(ap+apBinWidth/2,meanInitialRateAP);
idx = ~any(isnan(seInitialRateAP),1);
x = ap+apBinWidth/2;
er = errorbar(x(idx),meanInitialRateAP(idx), seInitialRateAP(idx));
xlim([.2 .9])
% ylim([0, 600])
set(gca,'YScale','log');
xlabel('fraction anterior-posterior')
ylabel('pol II loading rate(a.u./minute)')
standardizeFigure(gca, [], 'fontSize', 14)
set(er, 'LineStyle', '-')

figure(avgTimeOn)
hold on 
idXTimeOn = ~any(isnan(seTimeOnAP),1);
x = ap+apBinWidth/2;
erTimeON = errorbar(x(idXTimeOn),meanTimeOnAP(idXTimeOn), seTimeOnAP(idXTimeOn));
xlim([.2 .9])
ylim([-10 30])
% set(gca,'YScale','log');
xlabel('fraction anterior-posterior')
ylabel('time on (minutes)')
standardizeFigure(gca, [], 'fontSize', 14)
set(erTimeON, 'LineStyle', '-')
