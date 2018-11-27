% modified from the code by AR (livemRNAApp)

getMore = 0;
counter = 0;
% prefixes = {};
while getMore
    counter = counter + 1;
    prefixes{counter} = getPrefixAndFolder;%ExportDataForFISH;%
    disp(['You selected : ' prefixes{counter}])
    reply = input('Do you want to select more? (y/n)','s');
    if reply ~= 'y'
        getMore = 0;
    end
end

messageIcons = {'warn';'none'};
stateMessage = {'no';'yes'};
messageBoxSize = [196.5000  141.7500]; % width and height
positionTopLeft = [72.7500  372.0000]; % for the message box

functionNames = {...
'ExportDataForFISH';'filterMovie';'segmentSpots/segmentSpotsML'; 'TrackNuclei/StartTr2d';
'TrackmRNADynamics';'FindAPAxisFullEmbryo';'AddParticlePosition';
'CheckDivisionTimes';'CompileParticles'};
correspondingFunctionStates = zeros(1,length(functionNames));

for i = 1:length(prefixes)
    currentPrefix = prefixes{i};
    
    % Pulling folder information
    [SourcePath,FISHPath,DropboxFolder,MS2CodePath, PreProcPath,...
        Folder, Prefix, ExperimentType,Channel1,Channel2,OutputFolder,Channel3] = readMovieDatabase(currentPrefix);
    
    % Checking if files exists
    if exist([DropboxFolder,filesep,Prefix, filesep,'FrameInfo.mat'], 'file')
        index = strcmp('ExportDataForFISH',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    if exist([FISHPath,filesep,Prefix,'_'], 'dir')
        index = strcmp('filterMovie',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    if exist([DropboxFolder,filesep,Prefix, filesep,'Spots.mat'], 'file')
        index = strcmp('segmentSpots/segmentSpotsML',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    if exist([DropboxFolder,filesep, Prefix, filesep,Prefix,'_lin.mat'], 'file') && exist([DropboxFolder,filesep,Prefix, filesep,'Ellipses.mat'], 'file')
        index = strcmp('TrackNuclei/StartTr2d',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    if exist([DropboxFolder,filesep,Prefix, filesep,'Particles.mat'], 'file')
        load([DropboxFolder,filesep,Prefix, filesep,'Particles.mat'])
        if ~iscell(Particles)
            Particles = {Particles};
        end
        for Ch = 1:length(Particles)
            if isfield(Particles{Ch},'APpos')
                index = strcmp('AddParticlePosition',functionNames);
                correspondingFunctionStates(index) = 1;
            end
        end
        index = strcmp('TrackmRNADynamics',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    if exist([DropboxFolder,filesep,Prefix, filesep, 'APDetection.mat'], 'file')
        index = strcmp('FindAPAxisFullEmbryo',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    if exist([DropboxFolder,filesep,Prefix, filesep, 'APDivision.mat'], 'file')
        index = strcmp('CheckDivisionTimes',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    if exist([DropboxFolder,filesep,Prefix, filesep, 'CompiledParticles.mat'], 'file')
        index = strcmp('CompileParticles',functionNames);
        correspondingFunctionStates(index) = 1;
    end
    
    % Display what has been done...
    
    displayedText{1} = currentPrefix;
    for j = 1:length(correspondingFunctionStates)
        displayedText{j+1} = [functionNames{j} ' : ' ...
            stateMessage{correspondingFunctionStates(j)+1}];
    end
        
    status = msgbox(displayedText, ['Status ' num2str(i)],...
        messageIcons{(sum(correspondingFunctionStates)==length(correspondingFunctionStates))+1});
    currentPosition = positionTopLeft;%+[messageBoxSize(1)*(i-1) 0];
    set(status,'Position',[currentPosition messageBoxSize]);
end



