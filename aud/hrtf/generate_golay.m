function [a,b] = generate_golay(N)
% [a,b] = generate_golay(N)
%
% Generate the Golay codes a and b with length 2^N.
%
% Then write them to disk as golayA.wav and golayB.wav.
%
% Downloaded From (by CB)
% http://ccrma.stanford.edu/realsimple/imp_meas/generate_golay.m


% These initial a and b values are Golay
a = [1 1];
b = [1 -1];

% Iterate to create a longer Golay sequence
while (N>1)
    olda = a;
    oldb = b;
    a = [olda oldb];
    b = [olda -oldb];

    N = N - 1;
end

% Guess the sampling rate. It doesn't really matter.
fs = 96000;
a=a.*0.90;
b=b.*0.90;
% Scaling by 0.9999 suppresses a warning message about clipping.
wavwrite(a,fs,'golayA.wav');
wavwrite(b,fs,'golayB.wav');