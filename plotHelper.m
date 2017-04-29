[files,  fileDirs, seizureFiles, seizureFileDirs] = folderExplore('Datach', 'edf', 'seizures');
files_properties = [];
for i = 1: 1
    if(i < 10)
        file_summary_name = sprintf('chb0%d-summary.txt', i);
    else
        file_summary_name = sprintf('chb%d-summary.txt', i);
    end;
    if i<10
       dir_name = sprintf('ch0%d', i) 
    else
       dir_name =sprintf('ch%d', i);
    end;
    fileID = fopen(sprintf('Datach/%s/%s', dir_name, file_summary_name));
    file_line = fgets(fileID);
    while(strcmp(file_line(1,1:10), 'File Name:') == 0)
        file_line = fgets(fileID);
        while(size(file_line, 2) <= 10)
            file_line = fgets(fileID);
        end;
    end;
    
    while ischar(file_line)
        file_name = file_line(1, 11:end-1);
        file_line = fgets(fileID);
        formatSpec = 'File Start Time: %u:%u:%u\n';
        start_time = sscanf(file_line, formatSpec);
        formatSpec = 'File End Time: %u:%u:%u';
        file_line = fgets(fileID);
        end_time = sscanf(file_line, formatSpec);
        formatSpec = 'Number of Seizures in File: %u';
        file_line = fgets(fileID)
        nr_seizures = sscanf(file_line, formatSpec);
        seizure_start = zeros(1, nr_seizures);
        seizure_length = zeros(1, nr_seizures);
        for ii = 1: nr_seizures
            formatSpec = 'Seizure Start Time: %d seconds';
            file_line = fgets(fileID)
            s1 = sscanf(file_line, formatSpec)
            formatSpec = 'Seizure End Time: %d seconds';
            file_line = fgets(fileID)
            s2 = sscanf(file_line, formatSpec)
            seizure_start(1, ii) = s1;
            seizure_length(1, ii) = s2;
        end;
        file_line = fgets(fileID);
        file_line = fgets(fileID);
    end;
    fclose(fileID);
end;
