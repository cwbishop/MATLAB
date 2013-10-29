function win = complex_window(rampt, t, fs, sigstart, sigend, mn)
%wave = tone_shape(rampt, hz, t, fs)
%
%Generates a pure tone sine wave of the provided
%hz, time, and sampling frequency that is windowed 
%using a cosine ramp of a given duration. 
%
%INPUTS:
%  rampt - Duration of the cosine ramp
%  hz    - Frequency of the tone
%  t     - Duration of the tone in seconds
%  fs    - Sampling frequency. Default is 48000. 
%  sig   - Signal to be windowed. Used only if provided.

if ~exist('fs', 'var') || isempty(fs)
    fs = 48000;
end

%The neccessary cosine window frequency is found
%and then used to generate the base signal.
whz = (1 / (rampt * 2));
cosw = sin_gen(whz, 1, fs);

%Modifications are made to the signal to keep the
%values positive.
cosw = cosw + 1;
cosw = cosw ./ 2;

%The indices of the max and min of the final period
%are found and used to parse the signal for ramps.
zero = find(cosw(:) == 0);
one = find(cosw(:) == 1);
rise = (cosw(zero(length(zero)-1) : one(length(one))));
fall = (cosw(one(length(one)) : zero(length(zero))));

rise = (rise .* (mn - sigstart)) + sigstart;
fall = (fall .* (mn - sigend)) + sigend;

%The bridge is generated and then used to construct
%the complete window.
bridget = t - (2 * rampt);
bridge = ones(round(bridget * fs), 1);
bridge = bridge .* mn;
win = vertcat(rise, bridge);
win = vertcat(win, fall);

%The signal is generated on spec before the 
%window is applied to it element-wise.


