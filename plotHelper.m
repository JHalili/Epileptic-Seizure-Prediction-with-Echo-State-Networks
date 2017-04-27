filtered_data_show = 1;
channel_plot_start = 1;
channel_plot_end = 10;
channels = [4,7,14, 18]
if(filtered_data_show)
    S = FileContent(1, 'chb01_03.edf');
    figure;
    for i= 1:length(channels)
        subplot(length(channels), 1, i);
        plot(S.record(channels(i), :));
        title(sprintf('Channel %d',channels(i)));
    end;
    [start_seizure, length_seizure] = get_seizure_period('Datach/ch01/chb01_03.edf.seizures')

end;