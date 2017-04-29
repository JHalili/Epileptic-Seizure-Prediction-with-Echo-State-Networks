%% Go through all folders in a file
% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in
% that folder and all of its subfolders.
function [file_properties]  = folderExplore(name)
format longg;
format compact;
folderFormat = '/home/joana/Documents/Thesis/Script_Datach/%s';
% % Ask user to confirm or change.
topLevelFolder = sprintf(folderFormat, name);

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
% Process all image files in those folders.
chnl_base = struct('FP1_F7', 0, 'F7_T7', 0, 'T7_P7', 0 , ...
    'P7_O1', 0, 'FP1_F3', 0, 'F3_C3', 0, ...
    'C3_P3', 0, 'P3_O1', 0, 'FP2_F4', 0, ...
    'F4_C4', 0, 'C4_P4', 0, 'P4_O2', 0, ...
    'FP2_F8', 0, 'F8_T8', 0, 'T8_P8', 0, ...
    'P8_O2', 0, 'FZ_CZ', 0, 'CZ_PZ', 0, ...
    'P7_T7', 0, 'T7_FT9', 0, 'FT9_FT10', 0, ...
    'FT10_T8', 0);

file_counter = 0;
% for k = 2 : numberOfFolders
%     %     Get .edf files.
%     thisFolder = listOfFolderNames{k};
%     filePattern1 = sprintf('%s/*.%s', thisFolder, '.edf');
%     file_counter = file_counter + size(dir(filePattern1), 1);
% end;
for k = 2 : numberOfFolders
    % Get this folder and print it out.
    thisFolder = listOfFolderNames{k};
    i = k-1;
    if(i < 10)
        file_summary_name = sprintf('chb0%d-summary.txt', i);
    else
        file_summary_name = sprintf('chb%d-summary.txt', i);
    end;
    if i<10
        dir_name = sprintf('ch0%d', i);
    else
        dir_name =sprintf('ch%d', i);
    end;
    fileID = fopen(sprintf('Datach/%s/%s', dir_name, file_summary_name));
    chnl = chnl_base;
    % get rid of the first 5 lines in the begining
    for it = 1:5
        file_line = fgets(fileID);
    end;
    %read channels for this patients
    file_line = fgets(fileID);
    
    while(length(file_line) > 5 && (strcmp(file_line(1,1:7), 'Channel')==1))
        % we are still reading channel updates
        formatSpec = 'Channel %u: %s';
        rst = textscan(file_line, formatSpec);
        ch = rst(2);
        if(isfield(chnl, char(ch{1,1})))
            chnl.(char(ch{1,1})) = cell2mat(rst(1));
        end;
        file_line = fgets(fileID);
    end;
    file_line = fgets(fileID);
    while ischar(file_line)
        if(strcmp(file_line(1,1:11), 'File Name: ') == 1)
            file_counter = file_counter +1;
            file_name = file_line(1, 12:end-1);
            
            if(i ~= 24)
                file_line = fgets(fileID);
                formatSpec = 'File Start Time: %u:%u:%u\n';
                start_time = sscanf(file_line, formatSpec);
                formatSpec = 'File End Time: %u:%u:%u';
                file_line = fgets(fileID);
                end_time = sscanf(file_line, formatSpec);
            end;
            
            if(i == 24)
                start_time = 0;
                end_time = 0;
            end;
            
            formatSpec = 'Number of Seizures in File: %u';
            file_line = fgets(fileID);
            nr_seizures = sscanf(file_line, formatSpec);
            seizure_start = zeros(1, nr_seizures);
            seizure_length = zeros(1, nr_seizures);
            
            for ii = 1: nr_seizures
                formatSpec = 'Seizure %d Start Time: %d seconds';
                file_line = fgets(fileID);
                s1 = sscanf(file_line, formatSpec);
                formatSpec = 'Seizure %d End Time: %d seconds';
                file_line = fgets(fileID);
                s2 = sscanf(file_line, formatSpec);
                
                seizure_start(1, ii) = s1(2, 1);
                seizure_length(1, ii) = s2(2, 1);
            end;
            file_properties(file_counter).file_name = file_name;
            file_properties(file_counter).start_time = start_time;
            file_properties(file_counter).end_time = end_time;
            file_properties(file_counter).nr_seizures = nr_seizures;
            file_properties(file_counter).seizure_start = seizure_start;
            file_properties(file_counter).seizure_length = seizure_length;
            file_properties(file_counter).patient = i;
            file_properties(file_counter).channel_nr = chnl;
            file_line = fgets(fileID);
        else if(strcmp(file_line(1,1:11), 'Channels ch') == 1)
                chnl = chnl_base;
                %star rows
                file_line = fgets(fileID);
                file_line = fgets(fileID);
                while(length(file_line) > 5)
                    % we are still reading channel updates
                    formatSpec = 'Channel %u: %s';
                    rst = textscan(file_line, formatSpec);
                    ch = rst(2);
                    if(isfield(chnl, char(ch{1,1})))
                        chnl.(char(ch{1,1})) = cell2mat(rst(1));
                    end;
                    file_line = fgets(fileID);
                end;
            end;
        end;
        
        file_line = fgets(fileID);
    end;
    fclose(fileID);
end;

end