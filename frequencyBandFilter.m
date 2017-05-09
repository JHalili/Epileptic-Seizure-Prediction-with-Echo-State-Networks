function out = frequencyBandFilter( band, data, fs, averagingWindow )
%ALPHA BAND PASS FILTER (8-12)

[N,nu]=size(data);%obtain size of data
Fs = fs;  % Sampling Frequency

if(strcmp(band.name, 'delta') == 0)
    Fstop1 = band.Fstop1;             % First Stopband Frequency
    Fpass1 = band.Fpass1;               % First Passband Frequency
    Fpass2 = band.Fpass2;              % Second Passband Frequency
    Fstop2 = band.Fstop2;            % Second Stopband Frequency
    Dstop1 = band.Dstop1;          % First Stopband Attenuation
    Dpass  = band.Dpass;  % Passband Ripple
    Dstop2 = band.Dstop2;          % Second Stopband Attenuation
    dens   = band.dens;              % Density Factor
    
    % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
        0], [Dstop1 Dpass Dstop2]);
else
    Fpass = 0;               % Passband Frequency
    Fstop = 4;               % Stopband Frequency
    Dpass = 0.057501127785;  % Passband Ripple
    Dstop = 0.0001;          % Stopband Attenuation
    dens  = 20;              % Density Factor
    % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
end;
% Calculate the coefficients using the FIRPM function.
b3  = firpm(N, Fo, Ao, W, {dens});
Hd3 = dfilt.dffir(b3);
out=filter(Hd3,data);
out = out.^2;

g = gausswin(averagingWindow); % <-- this value determines the width of the smoothing window
g = g/sum(g);
out = conv(out, g, 'same');

out = out .* (1.0/max(out)) .*2 - 1;
end
