clear all;
clc;
files = folderExplore('Datach');
% generally for EEG data the decimation factor is 10
decimationFactor = 100;
Fs = 256 ;           % Sampling frequency
Fs1 = 256;
averagingWindow =  10000;
%% info on frequency bands
% delta = (0 - 4 Hz),
% theta (4 - 8 Hz)  ,
% alpha (8 - 16 Hz) ,
% beta (16 - 32 Hz) ,
% gamma (32 - 64 Hz).

%% channel names
channels = struct ( 'FP1_F7','FP1_F7' ,'F7_T7','F7_T7', 'T7_P7','T7_P7', ...
    'P7_O1','P7_O1', 'FP1_F3', 'FP1_F3',  'F3_C3', 'F3_C3', ...
    'C3_P3','C3_P3', 'P3_O1','P3_O1', 'FP2_F4', 'FP2_F4', 'F4_C4','F4_C4', ...
    'C4_P4','C4_P4', 'P4_O2','P4_O2', 'FP2_F8', 'FP2_F8', 'F8_T8','F8_T8', ...
    'T8_P8', 'T8_P8', 'P8_O2','P8_O2', 'FZ_CZ','FZ_CZ',  'CZ_PZ', 'CZ_PZ'); 


celldata = struct2cell(channels);

input_answ = [];
channelSim_computed = 0;
current_file = 1;
frequency_bands = setUpFrequencyBands();
%% test
for fid = 1:length(files)
    if(files(fid).patient == 12)
        continue;
    end;
    if(files(fid).patient ~= 14 && files(fid).patient ~=15)
        continue;
    end;
    file_name = files(fid).file_name;
    S = FileContent(files(fid).patient, file_name);
    M = [];
    data = zeros(5*length(celldata), size(resample(S.record(1, :),1,decimationFactor), 2));
    A = [];
    input_answ = [];
    %% Decimating output, getting rid of data we dont need.
    for ch = 1: length(celldata)
        helper = files(fid).channel_nr;
        if(helper.(celldata{ch, 1}) == 0 )
            continue;
        end;
        j = helper.(celldata{ch, 1});
        fprintf('%s channel in %d, file %s\n', celldata{ch, 1}, j, files(fid).file_name );
        
        %% apply notch filter to remove noise 50 OR 60 Hz
        % data is measured in the US using US devices, thus noise is
        % expected to be 60 Hz
        S_decimated = notchFilter(S.record(j, :), Fs, 60);
        %% separating into frequency bands and collecting singal energy for each band
        delta = frequencyBandFilter(frequency_bands.delta, S_decimated, Fs, averagingWindow);
        %disp 'delta done .. theta';
        theta = frequencyBandFilter(frequency_bands.theta, S_decimated, Fs, averagingWindow);
        %disp 'theta done ... alpha';
        alpha = frequencyBandFilter(frequency_bands.alpha, S_decimated, Fs, averagingWindow);
        %disp 'alpha done .. beta';
        beta  =  frequencyBandFilter(frequency_bands.beta, S_decimated, Fs, averagingWindow);
        %disp 'beta done .. gamma';
        gamma =  frequencyBandFilter(frequency_bands.gamma, S_decimated, Fs, averagingWindow);
        %disp 'gamma done .. hurray';
        data((ch-1)*5+1, :) =  resample(delta, 1,decimationFactor);
        data((ch-1)*5+2, :) =  resample(theta, 1,decimationFactor);
        data((ch-1)*5+3, :) =  resample(alpha, 1,decimationFactor);
        data((ch-1)*5+4, :) =  resample(beta, 1,decimationFactor);
        data((ch-1)*5+5, :) =  resample(gamma, 1,decimationFactor);
        if(channelSim_computed == 0)
            A = [A; S_decimated(1:300)];
        end;
        
    end;
    
    if(channelSim_computed == 0)
        % compute channel similarity matrix
        disp 'computing channel similarity matrix';
        channel_correlation = [];
        helper = [];
        for ch1=1:size(A, 1)
            for ch2=1:size(A, 1)
                a= corrcoef(A(ch1, :), A(ch2, :));
                helper = [helper, a(1,2)];
            end;
            channel_correlation = [channel_correlation; helper];
            helper = [];
        end;
        field_correlation_matrix = 'channel_correlation';
        value_correlation_matrix = channel_correlation;
        m = struct(field_correlation_matrix, value_correlation_matrix);
        save('correlationMatrix.mat', 'm');
        channelSim_computed = 1;
    end;
    
    Fs1 = Fs/decimationFactor;
    %Save preprocessed content and output in files    
    saveToFile(data, files(fid), Fs1, decimationFactor);
end;




