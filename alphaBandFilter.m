%% ALPHA
function out = alphaBandFilter(data, fs, averagingWindow)
%ALPHA BAND PASS FILTER (8-12)


Ts=600;% sampling period
[N,nu]=size(data);%obtain size of data
t=(1:N)*Ts;%generates time vector


Fs = fs;  % Sampling Frequency
Fstop1 = 7.5;             % First Stopband Frequency
Fpass1 = 8;               % First Passband Frequency
Fpass2 = 12;              % Second Passband Frequency
Fstop2 = 12.5;            % Second Stopband Frequency
Dstop1 = 0.0001;          % First Stopband Attenuation
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.0001;          % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
    0], [Dstop1 Dpass Dstop2]);
% Calculate the coefficients using the FIRPM function.
b3  = firpm(N, Fo, Ao, W, {dens});
Hd3 = dfilt.dffir(b3);
out=filter(Hd3,data);
out = out.^2;

g = gausswin(averagingWindow); % <-- this value determines the width of the smoothing window
g = g/sum(g);
out = conv(out, g, 'same');

out = out .* (1.0/max(out)) .*2 - 1;

plot_fig = 0;
if(plot_fig)
    f2 = figure;
    set(f2, 'name', 'alpha band smoothed', 'numbertitle', 'off');
    plot(out);
end;

end