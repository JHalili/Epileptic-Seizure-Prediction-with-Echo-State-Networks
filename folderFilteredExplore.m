%% Go through all folders in a file
% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in
% that folder and all of its subfolders.
function files  = folderFilteredExplore(name)
format longg;
format compact;
folderFormat = '/home/joana/Documents/Thesis/Script_Datach/%s';
% % Ask user to confirm or change.
topLevelFolder = sprintf(folderFormat, name)

% Get list of all subfolders.
allSubFolders = genpath(topLevelFolder);

% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
    [singleSubFolder, remain] = strtok(remain, ':');
    if isempty(singleSubFolder)
        break;
    end
    listOfFolderNames = [listOfFolderNames ;singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

file_counter = 0;
current_ptr = 1;
for k = 2 :2%  numberOfFolders
    % Get .mat files.
    thisFolder = listOfFolderNames{k};
    filePattern1 = sprintf('%s/*.mat', thisFolder)
    tt = dir(filePattern1)
    file_counter = file_counter + size(tt, 1)
    for ii = 1: size(tt, 1)
        files(ii+current_ptr-1).file_name = tt(ii, 1).name;
        if(k == 2)
            files(ii+current_ptr-1).patient = 24;
        else
            files(ii+current_ptr-1).patient = 3;
        end;
    end;
    current_ptr = file_counter;
end;

end

