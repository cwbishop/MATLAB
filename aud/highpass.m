function [d]=highpass(c,fhi,fs,order)

%
% function [d]=bandpass(c,flp,fhi,fs,order)
%
%highpass a time series with a 2nd order butterworth filter, unless
% specified by order
%
% c = input time series
% fhi = hipass cut frequency
% fs = sampling rate
%
if ~exist('order')
    order = 2;
end
n=order;      % 2nd order butterworth filter
fnq=(2*fs);  % Nyquist frequency
Wn=[fhi/fnq];    % butterworth bandpass non-dimensional frequency
[b,a]=butter(n,Wn,'high'); % construct the filter
d=filtfilt(b,a,c); % zero phase filter the data
return;