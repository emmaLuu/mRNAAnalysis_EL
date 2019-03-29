SourcePath = pathMaternal;

Folder = uigetdir(SourcePath,'Select folder with data');
[~, ~, LIFImages, LIFMeta] = loadLIFFile(Folder);

processedImage = {};
numberOfSeries = size(LIFImages,1);
for i = 1:numberOfSeries
    numberOfSlices = size(LIFImages{i},1);
    for j = 1:numberOfSlices
        currentSlice = LIFImages{i}{j};
        figure(1)
        subplot(1,2,1)
        %imshow(currentSlice,[])
        embryoMask = maskEmbryo(currentSlice);
        imshow(embryoMask)
        subplot(1,2,2)
        filteredImage = embryoMask*currentSlice;% This is not working at the moment.
        imshow(filteredImage)
    end
end

function mask = maskEmbryo(image)
   mask = bwareafilt(image>mean(image,'all'),1);
end

