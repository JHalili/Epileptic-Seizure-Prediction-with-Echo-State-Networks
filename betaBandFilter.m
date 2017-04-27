%% BETA
function out = betaBandFilter(data, fs, averagingWindow)

Fs = fs;  % Sampling Frequency

Fstop1 = 11.5;            % First Stopband Frequency
Fpass1 = 12;              % First Passband Frequency
Fpass2 = 30;              % Second Passband Frequency
Fstop2 = 30.5;            % Second Stopband Frequency
Dstop1 = 0.0001;          % First Stopband Attenuation
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.0001;          % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
    0], [Dstop1 Dpass Dstop2]);

% Calculate the coefficients using the FIRPM function
b4   = firpm(N, Fo, Ao, W, {dens});
Hd4 = dfilt.dffir(b4);
out=filter(Hd4,data);
out = out.^2;

g = gausswin(averagingWindow); % <-- this value determines the width of the smoothing window
g = g/sum(g);
out = conv(out, g, 'same');

% B = 1/averagingWindow*ones(averagingWindow,1);
% out = filter(B,1,out);


out = out .* (1.0/max(out)) .*2 - 1;

plot_fig = 0;
if(plot_fig)    
    f=figure;
    plot(out);
    set(f, 'name', 'beta band smoothed', 'numbertitle', 'off');
end;

end

