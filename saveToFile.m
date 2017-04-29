function saveToFile(data, type, chid, fid, fileName, fs)
%% Check for seizure
fformatSpec = '%s%s';
[start_seizure, length_seizure] = get_seizure_period(sprintf(fformatSpec,fileName, '.seizures'));

ten_min_thresh = 10*60*fs;
twenty_min_thresh = 2* ten_min_thresh;
sigma = ten_min_thresh;
% take lenght of any of the frequency bands
input_answ = zeros(1, size(data, 2));
if( (start_seizure ~= -1) && (length_seizure ~= -1))
    start_point = ceil(start_seizure * fs)
    end_point = ceil(length_seizure * fs + start_point)
    % check if we have ten minutes of data before the seizure;
    if(strcmp(type , 'gaussian') == 1)
        x = 1:1:size(data, 2);
        y =normpdf(x,start_point,sigma);
        y2 =normpdf(x,end_point,sigma/2);
        input_answ(1, 1: start_point) = input_answ(1, 1: start_point) + y(1, 1:start_point)*(1/max(y));
        input_answ(1, start_point : end_point-1) = ones(1, end_point-start_point);
        input_answ(1, end_point :end) =input_answ(1, end_point : end) + y2 (1, end_point:end)* (1/max(y2));
        
    end;
end;
%% Save input and response in a file
field_input_data = 'data';
value_input_data = data;


s = struct(field_input_data, value_input_data);

if(fid < 10)
    if(chid < 10)
        formatSpecFile = 'Datach_filtered/%s/ch0%d/chb0%d_0%d.mat';
    else
        formatSpecFile = 'Datach_filtered/%s/ch%d/chb%d_0%d.mat';
    end;
else
    if(chid <10)
        formatSpecFile = 'Datach_filtered/%s/ch0%d/chb0%d_%d.mat';
    else
        formatSpecFile = 'Datach_filtered/%s/ch%d/chb%d_%d.mat';
    end;
end;
filteredFileName = sprintf(formatSpecFile, 'data', chid, file_name(1, 1:end-3));
save(filteredFileName, 's');

field_teacher = 'teacher';
value_teacher = input_answ;

s_output = struct(field_teacher, value_teacher);
filteredFileName = sprintf(formatSpecFile, type, chid, chid, fid)
save(filteredFileName, 's_output');
end

