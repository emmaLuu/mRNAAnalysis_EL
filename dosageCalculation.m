function dosageCalculation(path,varargin)

% Update current method so that you call on the data status sheet to get
% the movies, loop through them. 

if ~isempty(varargin)
    for i = 1:length(varargin)
        if strcmpi(varargin{i},'folders')
            folders = varargin{i+1};
            getMore = 0;
        end
    end
else
    getMore = 1;
    folders = {};
end

sliceCounter = 0;
while getMore
    sliceCounter = sliceCounter + 1;
    [~,folders{sliceCounter}] = getPrefixAndFolder(path);%ExportDataForLivemRNA;%
    disp(['You selected : ' folders{sliceCounter}])
    reply = input('Do you want to select more? (y/n)','s');
    if reply ~= 'y'
        getMore = 0;
    end
end

% Calculations 
constructAvg = []; % might delete this later
constructCounter = 0;
% a struct called constructs will be made with the following loop
% Fields named 'individualNucleiAvg', 'seriesAvg'
for i = 1:length(folders)
    movieStruct = nucleiSegmentation('folder',folders{i});%,'showCircles');
    nucleiCount = [];
    correspondingAvg = [];
    sliceCounter = 0; % maybe change the code such that it is appending...
    
    % counting the nuclei and their avg (per slice)
    for j = 1:length(movieStruct)
        for k = 1:length(movieStruct(j).slice)
            sliceCounter = sliceCounter + 1;
            nucleiCount(sliceCounter) = length(movieStruct(j).slice(k).nuclei);
            if nucleiCount(sliceCounter) == 0
                correspondingAvg(sliceCounter) = NaN;
            else
                correspondingAvg(sliceCounter) = movieStruct(j).slice(k).mean;
            end
        end
    end
    
    % looking at the slices and the total number of nuclei
    figure()
    subplot(2,1,1)
    bar(1:length(nucleiCount),nucleiCount)
    title('Nuclei Count')
    ylabel('Number of Nuclei')
    
    subplot(2,1,2)
    bar(1:length(correspondingAvg),correspondingAvg)
    title('Avg Nucleoplasm Fluo')
    ylabel('Avg Nucleoplasm Fluo')
    
    sgtitle([folders{i} ' counts'])
    
    
    % find the slice with the most nuclei and take the average from that
    % slice as well as store the individual nuclei average
    %% STOPPED HERE! 
    seriesCounter = 0;
    seriesAvg = [];
    for j = 1:length(movieStruct)
        maxNucleiCount = 0;
        maxSliceIndex = 0;
        for k = 1:length(movieStruct(j).slice)
            currentCount = length(movieStruct(j).slice(k).nuclei);
            if currentCount > maxNucleiCount
                maxSliceIndex = k;
            end
        end
        seriesCounter = seriesCounter + 1;
        if maxSliceIndex
            seriesAvg(seriesCounter) = movieStruct(j).slice(maxSliceIndex).mean;
        else
            seriesAvg(seriesCounter) = NaN;
        end
    end
    
    constructCounter = constructCounter + 1;
    constructAvg(constructCounter) = mean(seriesAvg);
end

% Change this to a swarm plot
figure()
bar(1:length(constructAvg),constructAvg)

% labeling the x axis
% creating the label: 
constructLabels = {};
for i = 1:length(constructAvg)
    slashIndex = strfind(folders{i},'\');
    constructLabels{i} = folders{i}(slashIndex(end)+1:end);
end
xticks(1:length(constructAvg))
xticklabels(constructLabels)
title('Construct Averages')

figure()


% next steps:
% take the average of the series avg and store it in a variable
% have a loop that goes through all the constructs
% the final thing is to recreate the plot on the one note. 

end