function maternalPromoterPipeLineTest(Folder)
% later change the folder to prefix
% change the subfunctions to scripts?

close all
%SourcePath = pathMaternal;

%Folder = uigetdir(SourcePath,'Select folder with data');
[~, ~, LIFImages, ~] = loadLIFFile(Folder);

embryoClass = figure(1);
set(embryoClass,'Position',[9 49 496 635])
nucleiClass = figure(2);
set(nucleiClass,'Position',[521 49 496 635])

%processedImage = {};
numberOfSeries = size(LIFImages,1);
for i = 1%:numberOfSeries
    numberOfSlices = size(LIFImages{i},2);
    for j = 3%:numberOfSlices
        currentSlice = double(LIFImages{i}{j});
        
        figure(embryoClass)
        subplot(2,1,1)
        imshow(currentSlice,[])
        embryoMask = double(maskEmbryo(currentSlice));
        subplot(2,1,2)
        filteredImage = embryoMask.*currentSlice;% This is not working at the moment.
        imshow(filteredImage,[])
        
        figure(nucleiClass) 
        nucleiMaskFiltered = maskNuclei(filteredImage);
        nucleiMask = maskNuclei(currentSlice);

%         subplot(2,1,1)
%         nucleiFilteredImage = filteredImage.*nucleiMaskFiltered;
%         imshow(nucleiFilteredImage,[])
%         
%         subplot(2,1,2)
%         nucleiImage = currentSlice.*nucleiMask;
%         imshow(nucleiImage,[])
        threshold = mean(nonzeros(filteredImage));
        aboveFiltered = filteredImage.*...
            (filteredImage > threshold);
        subplot(2,2,1)
        imshow(imcomplement(aboveFiltered))
        
        subplot(2,2,2)
        [nucleiMaskFiltered,radii] = maskNuclei(filteredImage);%imcomplement(aboveFiltered));
        nucleiFilteredImage = filteredImage.*nucleiMaskFiltered;
        imshow(nucleiFilteredImage,[])
        
        subplot(2,2,3)
        histogram(radii,20)
        %pause(0.2)
    end
end

function mask = maskEmbryo(image)
   mask = bwareafilt(image>mean(image,'all'),1);
end

function [mask,radii] = maskNuclei(image)
    rMin = 3;
    rMax = 10;
    
    [centers,radii] = imfindcircles(image,[rMin rMax]);
    
    % First create the image.
    mask = zeros(size(image));
    imageSizeX = size(image,1);
    imageSizeY = size(image,2);
    [columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

    for k = 1:size(centers,1)
        singleCircle = drawBinaryCircle(columnsInImage,rowsInImage,...
            centers(k,:),radii(k));
        mask = mask + singleCircle;
    end
end

function circle = drawBinaryCircle(columnsInImage,rowsInImage,center,radius)
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

end

