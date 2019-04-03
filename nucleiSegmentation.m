function embryo = nucleiSegmentation(Folder)
% later change the folder to prefix
% make the final version of the subfunctions scripts

close all
if isempty(Folder)
    %SourcePath = ; % copy this from getPrefixAndFolder
    Folder = uigetdir('Select folder with data');
end

[~, ~, LIFImages, ~] = loadLIFFile(Folder);

% setting figures
imageFigure = figure(1);
set(imageFigure,'Position',[9 49 496 635])
nucleiClass = figure(2);
set(nucleiClass,'Position',[521 49 496 635])

% defining variables
sigma = 1;
rMin = 3;
rMax = 10;

%processedImage = {};
numberOfSeries = size(LIFImages,1);
for i = 1:numberOfSeries
    numberOfSlices = size(LIFImages,2);
    for j = 1:numberOfSlices
        currentSlice = double(LIFImages{i}{j});
        embryoMask = double(maskEmbryo(currentSlice));
        embryoOnly = embryoMask.*currentSlice;
        
%         % a gui for a quick glance at the diameter of the nuclei
%         figure('units','normalized','outerposition',[0 0 1 1])
%         imshow(currentSlice,[])
%         d = imdistline; % measuring diameter of circles

        figure(imageFigure) %--------------------------------
        imshow(imgaussfilt(embryoOnly,sigma),[])
        hold on        
        
        % Nuclear classification 
        % note: find a way so that it does not classify parts of the edge of the 
        % embryo as a nucleus
        nuclei = generateNuclearMask(embryoOnly,...
            'sigma',sigma,'radiusRange',[rMin rMax]);%,...
            %'showCircles',nucleiClass);
        
        if ~isempty(nuclei)
            meanFluo = computeMeanFluo(nuclei,currentSlice);
        else
            meanFluo = [];
        end
        
        embryo(i).slice(j).nuclei = nuclei;
        embryo(i).slice(j).mean = meanFluo; % the total mean of the slice
            
%         threshold = mean(nonzeros(filteredImage));
        pause(0.25)
    end
end


% Calculations 

nucleiCount = [];
correspondingAvg = [];

counter = 0;
for i = 1:length(embryo)
    for j = 1:length(embryo(i).slice)
        counter = counter + 1;
        nucleiCount(counter) = length(embryo(i).slice(j).nuclei);
        correspondingAvg(counter) = embryo(i).slice(j).mean;
    end
end

figure()
subplot(2,1,1)
bar([1:length(nucleiCount)],nucleiCount)
title('Nuclei Count')

subplot(2,1,2)
bar([1:length(correspondingAvg)],correspondingAvg)
title('Avg Nucleoplasm Fluo')

end


function mask = maskEmbryo(image)
mask = bwareafilt(image>mean(image,'all'),1);
end

function nucleus = generateNuclearMask(image,varargin)
% This function takes an image and applies a 2D gaussian
% filter to that image. Nuclei are identified and a nuclear mask is
% created for each one is created. A structure with fields "mask","center",
% and "radius" is returned. 

% Default values that can be changed by user
rMin = 3;
rMax = 10;
sigma = 2;
show = 0;

% Looking at user's input
if ~isempty(varargin)
    for i = 1:length(varargin)
        if strcmpi(varargin{i},'radiusRange')
            radiusRange = varargin{i+1};
            rMin = radiusRange(1);
            rMax = radiusRange(2);
        elseif strcmpi(varargin{i},'sigma')
            sigma = varargin{i+1};
        elseif strcmpi(varargin{i},'showCircles')
            show = 1;
            figureHandle = varargin{i+1};
        end
    end
end

% applying 2D gaussian filter
blurredImage = imgaussfilt(image,sigma);

% identifiying nuclei center and radius
[centers,radii] = imfindcircles(blurredImage,[rMin rMax],...
    'ObjectPolarity','dark');

% plotting given image and an overlay of the nuclei identified
if show && ~isempty(centers) 
    figure(figureHandle)
    % showing the circles included in the mask
    imshow(image,[])
    viscircles(centers, radii,'Color','b');
end

% Creating mask for each nuclei
imageSizeX = size(image,1);
imageSizeY = size(image,2);
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

for k = 1:size(centers,1)
    singleCircle = drawFilledCircle(columnsInImage,rowsInImage,...
        centers(k,:),radii(k));
    
    % storing the mask, center, and radius of each nucleus
    nucleus(k).mask = singleCircle;
    nucleus(k).center = centers(k,:);
    nucleus(k).radius = radii(k);
end

if isempty(centers)
    nucleus = [];
end

end

function totalMean = computeMeanFluo(nucleus,image)
% This function takes a struct of the nuclear mask and the original
% interest and created a new field called "average" which will have the
% average of the corresponding nucleus. It will return the total mean of
% the nuclei.

mask = zeros(size(image));

for i = 1:length(nucleus)
    currentNucleus = image.*nucleus(i).mask;
    nucleus(i).average = mean(nonzeros(currentNucleus));
    mask = mask + nucleus(i).mask;
end

allNucleiFluo = mask.*image;
totalMean = mean(nonzeros(allNucleiFluo));
end

function circle = drawFilledCircle(columnsInImage,rowsInImage,center,radius)
% Adds a logical image of a circle with specified
% diameter, center, and image size.
% Next create the circle in the given image.

centerX = center(1);
centerY = center(2);
circle = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;

%image(circle) ;
%colormap([0 0 0; 1 1 1]);
end


