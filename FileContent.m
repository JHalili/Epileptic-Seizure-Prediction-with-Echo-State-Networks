%% Get file content from a edf in Datach
% Data contet all represented in the header
% record contains signal
classdef FileContent    
    properties
        hdr;
        record;
        file_name;
    end
    
    methods       
        % need to take care of seizure files, yet not important for now
        function obj = FileContent(chid, file_nm)
            
                if(chid < 10)
                    formatSpec = 'Datach/ch0%d/%s';
                else
                    formatSpec = 'Datach/ch%d/%s';
                end;
             
            obj.file_name = sprintf(formatSpec, chid, file_nm)
            obj.file_name
            [obj.hdr, obj.record] = edfread(obj.file_name);
        end
    end    
end

