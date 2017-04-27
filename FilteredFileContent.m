%datset with varying number of electrodes
%frequency assembled is 5000 Hz
%human data 4 hours before or after a seizure
classdef FilteredFileContent
    properties
        data;
        teacher;
        file_nr;
        file_type;
    end
    
    methods
        function obj = FilteredFileContent( chid, file_name)
            
            if(chid < 10)
                formatSpec = 'Datach_filtered/%s/ch0%d/%s';
            else
                formatSpec = 'Datach_filtered/%s/ch%d/%s';
            end;
            S = load(sprintf(formatSpec,'data', chid, file_name));
            %S = memmapfile(sprintf(formatSpec,'data', chid, file_name));
            
            names = fieldnames(S);
            obj.data = S.(names{1}).data;
            
            S_out = load(sprintf(formatSpec, 'gaussian', chid, file_name));
            %S_out = memmapfile(sprintf(formatSpec, 'gaussian', chid, file_name));
            names = fieldnames(S_out);
            obj.teacher = S_out.(names{1}).teacher;
            
        end
        function plotContent(obj, channel_nr_start, channel_nr)
            disp 'Plotting now';
            f1 = figure;
            set(f1, 'name', 'dat smoothed', 'numbertitle', 'off');
            for i = channel_nr_start:channel_nr
                subplot(channel_nr-channel_nr_start+1, 1, i-channel_nr_start+1);
                plot(obj.data(i, :));
            end;
            
            f6 = figure;
            set(f6, 'name', 'teacher', 'numbertitle', 'off');
            plot(obj.teacher);
            
        end
    end
end



