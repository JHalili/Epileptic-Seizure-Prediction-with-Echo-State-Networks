%% initialize
decimationFactor = 100;
Fs = 256 ;
fs = Fs/decimationFactor;
files_all = folderExplore('Datach');

ch4_files = [ 'chb03_01_seizure1.mat';'chb03_02_seizure1.mat'; 'chb03_03_seizure1.mat';...
    'chb03_04_seizure1.mat'; 'chb03_34_seizure1.mat'; 'chb03_35_seizure1.mat';...
    'chb03_36_seizure1.mat'; 'chb24_01_seizure1.mat'; 'chb24_01_seizure2.mat';...
    'chb24_03_seizure1.mat'; 'chb24_03_seizure2.mat'; 'chb24_04_seizure1.mat';...
    'chb24_04_seizure2.mat'; 'chb24_04_seizure3.mat'; 'chb24_06_seizure1.mat';...
    'chb24_07_seizure1.mat'; 'chb24_09_seizure1.mat'; 'chb24_11_seizure1.mat';...
    'chb24_13_seizure1.mat'; 'chb24_14_seizure1.mat'; 'chb24_15_seizure1.mat';...
    'chb24_17_seizure1.mat'; 'chb24_21_seizure1.mat'];

C = cellstr(ch4_files);
%%
current_file = 0;
for ii = 1: length(files_all)
    if(files_all(ii).patient ~= 3 && files_all(ii).patient ~= 24)
        continue;
    end;
    
    file = files_all(ii);
    tst = file.file_name
    if(file.nr_seizures ~=0 )
        if(file.patient == 3)
            formatSpecFile = 'Datach_filtered/test/ch03/%s';
        else
            formatSpecFile = 'Datach_filtered/test/ch24/%s';
        end;
        
        ten_min_thresh = 10*60*fs;
        sigma = ten_min_thresh;
        % take lenght of any of the frequency bands
        
        for i=1:file.nr_seizures
            
            
            current_file = current_file + 1;
            st = C(current_file);
            sprintf(formatSpecFile,st{1,1})
            S = load(sprintf(formatSpecFile,st{1,1}));
            data = S.s.data;
            x = 1:1:size(data, 2);
            y =normpdf(x,size(data, 2),sigma);
            y = y/max(y);
            figure;
            plot(y)
            
            s = struct('data', data, 'teacher', y);
            
            save(sprintf(formatSpecFile, st{1,1}), 's');
            disp 'saved';
        end;
    end;
end;
