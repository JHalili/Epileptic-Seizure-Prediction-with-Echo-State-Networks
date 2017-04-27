%% DELTA
function out = deltaBandFilter(data, fs, averagingWindow)

Fs = fs;  % Sampling Frequency
Fpass = 0;               % Passband Frequency
Fstop = 4;               % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor
% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b1 = firpm(N, Fo, Ao, W, {dens});
Hd1 = dfilt.dffir(b1);
out=filter(Hd1,data);
out = out.^2;

% Smoothing
g = gausswin(averagingWindow); % <-- this value determines the width of the smoothing window
g = g/sum(g);
out = conv(out, g, 'same');

out = out .* (1.0/max(out)) .*2 - 1;

plot_fig=0;
if(plot_fig)    
    f= figure;
    plot(out);
    set(f,'name','delta band','numbertitle','off');
end;
end