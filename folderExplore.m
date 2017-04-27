%% Go through all folders in a file
% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in 
% that folder and all of its subfolders.
function [baseFileNames,folderFileNumber, ...
          baseFileNamesSeizure, folderSeizureFileNumber]  = folderExplore(name, pattern1, pattern2)
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
numberOfFolders = length(listOfFolderNames)
baseFileNames = [];
folderFileNumber = [];
folderSeizureFileNumber = [];
baseFileNamesSeizure = [];
% Process all image files in those folders.
for k = 2 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	
	% Get PNG files.
	filePattern1 = sprintf('%s/*.%s', thisFolder, pattern1);
    [a1,b1] = size(dir(filePattern1));
    folderFileNumber = horzcat(folderFileNumber, a1);
 	baseFileNames =vertcat(baseFileNames , dir(filePattern1));
    
    filePattern2 = sprintf('%s/*.%s', thisFolder, pattern2);
    [a2,b2] = size(dir(filePattern2));
    folderSeizureFileNumber = horzcat(folderSeizureFileNumber, a2);
 	baseFileNamesSeizure =vertcat(baseFileNamesSeizure , dir(filePattern2));
    
end
end