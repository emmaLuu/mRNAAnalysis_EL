prefixHalf3 = '2018-11-07-half_bcd_opt_3';
[~,~,DefaultDropboxFolder,~,~] = DetermineLocalFolders;

[~,~,DropboxFolder,~,~]=...
    DetermineLocalFolders(prefixHalf3);

DataFolder=[DropboxFolder,filesep,prefixHalf3];

FilePrefix=[DataFolder(length(DropboxFolder)+2:end),'_'];

[~,~,DropboxFolder,~,PreProcPath]=...
    DetermineLocalFolders(FilePrefix(1:end-1));

nameSuffix = '_ch01';
NDigits=3;

stillLooking = 1;
CurrentZ = 16;
CurrentFrame = 101;
sharpCoeff = [0 0 0;0 1 0;0 0 0]-fspecial('laplacian',0.2);
sigma = 1.5;
while stillLooking
    try
        AboveZ = CurrentZ + 1;
        BelowZ = CurrentZ - 1;
        
        %Above Current Z
        ImageAbove=imread([PreProcPath,filesep,FilePrefix(1:end-1),filesep,...
            FilePrefix,iIndex(CurrentFrame,NDigits),'_z',...
            iIndex(AboveZ,2),nameSuffix,'.tif']);
        %         ImageAboveSharp = imfilter(ImageAbove,sharpCoeff,'symmetric');
        ImageAboveBlur = imgaussfilt(ImageAbove, sigma);
        % plotting them together
        figure('Name',['Z = ' num2str(AboveZ)])
        imshowpair(ImageAbove,ImageAboveBlur,'montage','Scaling','joint')
        title('Original Image and Modified Image')
       
        figure('Name',['Blended Z = ' num2str(AboveZ)])
        imshowpair(ImageAbove,ImageAboveBlur,'blend','Scaling','joint')
        title('Original Image and Modified Image')
        
        %At Current Z
        ImageMiddle=imread([PreProcPath,filesep,FilePrefix(1:end-1),filesep,...
            FilePrefix,iIndex(CurrentFrame,NDigits),'_z',...
            iIndex(CurrentZ,2),nameSuffix,'.tif']);
        %         ImageMiddleSharp = imfilter(ImageMiddle,sharpCoeff,'symmetric');
        ImageMiddleBlur = imgaussfilt(ImageMiddle, sigma);
        % plotting them together
        figure('Name',['Z = ' num2str(CurrentZ)])
        imshowpair(ImageMiddle,ImageMiddleBlur,'montage','Scaling','joint')
        title('Original Image and Modified Image')
        
        figure('Name',['Blended Z = ' num2str(CurrentZ)])
        imshowpair(ImageMiddle,ImageMiddleBlur,'blend','Scaling','joint')
        title('Original Image and Modified Image')
        
        %Below Current Z
        ImageBelow=imread([PreProcPath,filesep,FilePrefix(1:end-1),filesep,...
            FilePrefix,iIndex(CurrentFrame,NDigits),'_z',...
            iIndex(BelowZ,2),nameSuffix,'.tif']);
        %         ImageBelowSharp = imfilter(ImageBelow,sharpCoeff,'symmetric');
        ImageBelowBlur = imgaussfilt(ImageMiddle, sigma);
        % plotting them together
        figure('Name',['Z = ' num2str(BelowZ)])
        imshowpair(ImageBelow,ImageBelowBlur,'montage','Scaling','joint')
        title('Original Image and Modified Image')
        
        figure('Name',['Blended Z = ' num2str(BelowZ)])
        imshowpair(ImageBelow,ImageBelowBlur,'blend','Scaling','joint')
        title('Original Image and Modified Image')
        
    catch
        disp('You are asking for something outside of the Z stack!')
    end
    
    theUsersInput = input('Still looking? (y/n)','s');
    
    if strcmpi(theUsersInput,'y')
        CurrentZ = input('What Z slice do you want center on now? (Choose between 2 and 20,inclusive)');
        CurrentFrame = input(['What frame do you want to look at? Current Frame: ' num2str(CurrentFrame)]);
        close all;
    else
        stillLooking = 0;
    end
end