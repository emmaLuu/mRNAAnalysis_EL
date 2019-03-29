% This function is meant to check through the folders in the path given
% for the subfolders of interest;
% For example, to use this to see if FullEmbryo is a subfolder of the 
% movies of BcdE1 the following variables were set as shown below: 
%
% path = 'E:\SyntheticEnhancers\Data\RawDynamicsData\';
% folderNameSearch = 'E1';
% subFolderSearch = 'FullEmbryo';

path = 'E:\SyntheticEnhancers\Data\RawDynamicsData\';
folderNameSearch = 'E1';
subFolderSearch = 'FullEmbryo';
A = dir(path);

with = {};
without = {};
counterWith = 0;
counterWithout = 0;
for i = 3:length(A)
    B = dir([path,filesep,A(i).name]);
    for j = 1:length(B) 
        k = strfind(B(j).name,folderNameSearch);
        if sum(k) 
            C = dir([path,filesep,A(i).name,filesep,B(j).name]);
            totalM = 0;
            for l = 1:length(C)
                m = strfind(C(l).name,subFolderSearch);
                totalM = totalM + sum(m);
            end
            
            if totalM
                counterWith = counterWith + 1;
                with{counterWith} = [A(i).name,filesep, B(j).name];
            else
                counterWithout = counterWithout + 1;
                without{counterWithout} = [A(i).name,filesep, B(j).name];
            end
        end
    end
end


for i = 1:length(with)
    disp([with{i},' with'])
end

for i = 1:length(without)
    disp([without{i},' without'])
end