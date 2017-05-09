ch3_files = ['chb03_01_seizure1.mat', 'chb03_02_seizure1.mat', 'chb03_34_seizure1.mat',...
'chb03_03_seizure1.mat', 'chb03_35_seizure1.mat', 'chb03_04_seizure1.mat',... 
'chb03_36_seizure1.mat'];

ch4_files = ['chb24_01_seizure1.mat', 'chb24_01_seizure2.mat', 'chb24_17_seizure1.mat', ...
'chb24_09_seizure1.mat', 'chb24_03_seizure1.mat', 'chb24_03_seizure2.mat', ....
'chb24_04_seizure1.mat', 'chb24_11_seizure1.mat', 'chb24_04_seizure2.mat', ...
'chb24_04_seizure3.mat', 'chb24_13_seizure1.mat', 'chb24_14_seizure1.mat', ...
'chb24_06_seizure1.mat', 'chb24_15_seizure1.mat','chb24_07_seizure1.mat', ...
'chb24_21_seizure1.mat'];

files_all = folderExplore('Datach');
for i = 1: length(files_all)
    if(files_all(i).patient ~= 3 && files_all(i).patient ~= 24)
        continue;
    end;
    
    
fformatSpec = '%s%s';
ten_min_thresh = 10*60*fs;
one_min_thresh = floor(ten_min_thresh / 10);
sigma = ten_min_thresh;
% take lenght of any of the frequency bands
input_answ = zeros(1, size(data, 2));
current_pos = 1;
type_seizure_predict = 'seizure_predictor';
if(file.patient < 10)
    formatSpecFile = 'Datach_filtered/%s/ch0%d/%s.mat';
else
    formatSpecFile = 'Datach_filtered/%s/ch%d/%s.mat';
end;
if(file.nr_seizures ~=0 )
    x = 1:1:size(data, 2);
    for i=1:file.nr_seizures
        
        start_point = ceil(file.seizure_start(i) * fs);
        end_point = ceil(file.seizure_end(1) * fs );
        if((start_point - current_pos) < ten_min_thresh)
            %seizure must not be considered and thus dropped
            curent_pos = end_point;
            continue;
        end;
        
        input_answ = zeros(1, size(data, 2));
        y =normpdf(x,start_point,sigma);
        y = y/max(y);
        input_answ(1, current_pos: start_point) = ...
               input_answ(1, current_pos: start_point)...
               + y(1, current_pos:start_point);
        s = struct('data', data(:, current_pos: start_point),...
                    'teacher', input_answ(1, current_pos:start_point));
        fileName = sprintf('%s_%s%d',file.file_name(1, 1:end-4), 'seizure', i);
        filteredFileName = sprintf(formatSpecFile, type_seizure_predict,...
                                                    file.patient, fileName)
        save(filteredFileName, 's');
        disp 'saved';
        current_pos = end_point;
    end;
end;
