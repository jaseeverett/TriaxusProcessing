% This script will move all the required files to one directory.
% Note: You need to turn Triaxus_IN2016v05 into a function to run the program

clear
close all

direc = '~/GitHub/TriaxusProcessing/all_files/';

master_file = 'Triaxus_Process_VoyageName';

if exist(direc,'dir') == 0
    mkdir(direc)
end

[fList] = matlab.codetools.requiredFilesAndProducts(master_file);

for a = 1:length(fList)
    
    file = fList{a};
    
    fi = strfind(file,'/'); fi = fi(end)+1;
    if strcmp(file(fi:end),master_file) == 0        
        eval(['!cp ',file,' ',[direc,file(fi:end)],''])
    end
end

