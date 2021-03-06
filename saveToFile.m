function saveToFile(data, file, fs, decimationFactor)
%% Check for seizure
fformatSpec = '%s%s';
ten_min_thresh = 10*60*fs;
one_min_thresh = floor(ten_min_thresh / 10);
sigma = one_min_thresh;
% take lenght of any of the frequency bands
input_answ = zeros(1, size(data, 2));
input_answ_seizure = zeros(1, size(data, 2));
current_pos = 1;
type_seizure_detect = 'seizure_detector';
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
else
    %only save data in small amounts (ten min data)
    disp 'not a seizure file';
    name_count = 1;
    i = 1;
    while(i < size(data, 2))
        if( i + ten_min_thresh > size(data, 2))
            s = struct('data', data(:, i:end),...
                        'teacher', input_answ(:, i: end));
        else
            s = struct('data', data(:, i: i+ten_min_thresh-1), ...
                       'teacher', input_answ(:, i: i+ten_min_thresh-1));
        end;
        i = i+ten_min_thresh;
        fileName = sprintf('%s_%d',file.file_name(1, 1:end-4), name_count)
        filteredFileName = sprintf(formatSpecFile, type_seizure_predict, ...
                                                    file.patient, fileName);
        save(filteredFileName, 's');
        name_count = name_count +1;
    end;   
end;

end

