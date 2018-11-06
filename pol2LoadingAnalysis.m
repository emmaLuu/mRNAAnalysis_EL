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

%% plotting with continous AP axis
figure()
hold on
colorsUsed = {};
meansOfSets = [];
plotsLabeled = plot(NaN,NaN);
names = {'placeHolder'};
allAPPositions = [];
allInitialSlopes = [];
allSlopeError = []; % the error is taken to be the norm of the residuals

for currentDataSet = dataSetsToInclude
    numberOfParticles = length(data(currentDataSet).Particles);
    labelPlot = 0; %condition 
    clear apPositions
    currentInitialSlopes = NaN(1,numberOfParticles);
    errorEstimations = NaN(1,numberOfParticles);
    for currentParticle = 1:numberOfParticles
        apPositions(currentParticle) = mean(data(currentDataSet).Particles(currentParticle).APpos);
        try
            tempSlope = ...
                data(currentDataSet).fittedLineEquations(currentParticle).Coefficients(1,1);
            if tempSlope >= 0
                currentInitialSlopes(currentParticle) = tempSlope;
                errorEstimations(currentParticle) =...
                    data(currentDataSet).fittedLineEquations(currentParticle).ErrorEstimation(1).normr/...
                    data(currentDataSet).fittedLineEquations(currentParticle).numberOfParticlesUsedForFit(1);
            end
        end
    end
    
    %Storing these values
    allAPPositions(end+1:end+numberOfParticles) = apPositions;
    allInitialSlopes(end+1:end+numberOfParticles) = currentInitialSlopes;
    allSlopeError(end+1:end+numberOfParticles) = errorEstimations;
    
    %Plotting the error bars
    errorbar(apPositions, currentInitialSlopes,errorEstimations,'.',...
        'Color','black');%allColors(currentDataSet,:));
    %Plotting the values 
    plotsLabeled(end+1) = plot(apPositions,currentInitialSlopes,'.','MarkerSize',15,...
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
        names{end+1} = nameTemp{end};
    end
end
legend([plotsLabeled(2:end)],{names{2:end}}, 'Interpreter', 'none');
xlim([0 1])
xlabel('Embryo Length (%)')
ylabel('Initial Rate (a.u./minute)')
set(gcf,'Position',[4.5000 43.5000 679 601])
set(gca,'YScale','log')


%% plotting with binned ap
ap = data(1).APbinID;
apBinWidth = ap(2)-ap(1);
apMid = ap+apBinWidth/2;
apMidString = cellstr(string(ap+apBinWidth/2));
numAPBins = length(ap);
meanInitialRateAP = NaN(1,numAPBins);
seInitialRateAP = NaN(1,numAPBins);
apBinGrouping = NaN(1,length(allInitialSlopes)); % stores corresponding bin string for allInitialSlopes

% binPlots = plot(NaN,NaN);
% binNames = {'placeholder'};
for currentAPBinIndex = 2:numAPBins % index of upper bound of ap
    lowerBound = ap(currentAPBinIndex-1);
    upperBound = ap(currentAPBinIndex);
    pointsIncluded = (allAPPositions>lowerBound) & (allAPPositions<upperBound);
    apBinGrouping(pointsIncluded) = round(mean([lowerBound,upperBound]),2,'significant');
    meanInitialRateAP(currentAPBinIndex-1) = nanmean(allInitialSlopes(pointsIncluded));
    denom = sqrt(sum(~isnan((allInitialSlopes(pointsIncluded)))));
    if ~denom
        denom = 1;
    end
    seInitialRateAP(currentAPBinIndex-1) = nanstd(allInitialSlopes(pointsIncluded))/denom;
  %     if sum(pointsIncluded)
%         binPlots(end+1) = plot(allAPPositions(pointsIncluded),...
%             allInitialSlopes(pointsIncluded),'.','MarkerSize',10);
%     end
end

figure()
boxplot(allInitialSlopes,apBinGrouping,'PlotStyle','Compact')
set(gcf,'Position',[693 43.5000 585.5000 215])

figure()
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
set(gcf,'Position',[692 319 583 325.5000])
standardizeFigure(gca, [], 'fontSize', 14)
set(er, 'LineStyle', '-')

