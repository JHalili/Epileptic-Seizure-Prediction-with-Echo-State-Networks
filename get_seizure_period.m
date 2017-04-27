function [ seizure_start_time_offset_in_seconds, ...
    seizure_length_in_seconds ] = get_seizure_period( annotation_file_location )

[file_descriptor, message] = fopen(annotation_file_location);
if file_descriptor < 0
    disp 'file not found'
    annotation_file_location
    seizure_start_time_offset_in_seconds = -1;
    seizure_length_in_seconds = -1;
else
    byte_array = fread(file_descriptor);
    
    seizure_start_time_offset_in_seconds = bin2dec(...
        strcat(dec2bin(byte_array(39)),dec2bin(byte_array(42))));
    
    seizure_length_in_seconds = byte_array(50);
end;

end