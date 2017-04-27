clear all;
clc;
[files,  fileDirs, seizureFiles, seizureFileDirs] = folderExplore('Datach', 'edf', 'seizures');
total_file_nr = sum(fileDirs);
channel_nr = 23;
% generally for EEG data the decimation factor is 10
decimationFactor = 100;
Fs = 256 ;           % Sampling frequency
Fs1 = 256;
T = 1/Fs;             % Sampling period
L = 600;             % Length of signal
t = (0:L-1)*T;        % Time vector
averagingWindow = 10000;
%% info on frequency bands
% delta = (0 - 4 Hz),
% theta (4 - 8 Hz)  ,
% alpha (8 - 16 Hz) ,
% beta (16 - 32 Hz) ,
% gamma (32 - 64 Hz).
input_answ = [];
channelSim_computed = 0;
current_file = 0;
for chid = 1 : length(fileDirs)
    ch_file_nr = fileDirs(chid);
    for fid = 1:ch_file_nr
        current_file = current_file +1;
        if(current_file > 16)
            continue;
        end;
        file_name = files(current_file).name;
        file_name
        continue;
        S = FileContent(chid, file_name);
        M = [];
        data = [];
        A = [];
        input_answ = [];
        %% Decimating output, getting rid of data we dont need.
        for j = 1:channel_nr
            
            fprintf('%d channel, file %s\n', j,file_name );
            
            %% apply notch filter to remove noise 50 OR 60 Hz
            % data is measured in the US using US devices, thus noise is
            % expected to be 60 Hz
            S_decimated = notchFilter(S.record(j, :), Fs/decimationFactor, 60);
            %% separating into frequency bands and collecting singal energy for each band
            delta = deltaBandFilter(S_decimated, Fs, averagingWindow);
            disp 'delta done .. theta';
            theta = thetaBandFilter(S_decimated, Fs, averagingWindow);
            disp 'theta done ... alpha';
            alpha = alphaBandFilter(S_decimated, Fs, averagingWindow);
            disp 'alpha done .. beta';
            beta  =  betaBandFilter(S_decimated, Fs, averagingWindow);
            disp 'beta done .. gamma';
            gamma =  gammaBandFilter(S_decimated, Fs, averagingWindow);
            disp 'gamma done .. hurray';
            data = [data; resample(delta, 1,decimationFactor)];
            data = [data; resample(theta, 1,decimationFactor)];
            data = [data; resample(alpha, 1,decimationFactor)];
            data = [data; resample(beta, 1,decimationFactor)];
            data = [data; resample(gamma, 1,decimationFactor)];
            if(channelSim_computed == 0)
                A = [A; S_decimated(1:300)];
            end;
            
        end;
        
        if(channelSim_computed == 0)
            % compute channel similarity matrix
            disp 'computing channel similarity matrix';
            channel_correlation = [];
            helper = [];
            for ch1=1:channel_nr
                for ch2=1:channel_nr
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
        %Save input and response in a file
        size(data)
%         saveToFile(data, 'descrete',...
%             chid, fid, S.file_name, Fs1);
        
        saveToFile(data, 'gaussian', ...
            chid, fid, S.file_name, Fs1);
        
    end;
end;




