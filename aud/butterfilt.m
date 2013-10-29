function [data]=butterfilt(data,lower,higher,fs,order_lowcut,order_highcut,plot_f)
%
% [data]=butterfilt(data,lower,higher,fs,order_lowcut,order_highcut,plot_f)



if ~exist('plot_f')
    plot_f = 0;
end

if lower %highpass first
    fnq=(fs/2);  % Nyquist frequency
    Wn=[lower/fnq];    % butterworth bandpass non-dimensional frequency
    [b,a]=butter(order_lowcut,Wn,'high'); % construct the filter
    data=filtfilt(b,a,data); % zero phase filter the data
    if plot_f
        figure
        freqz(b,a);
    end
end

if higher %lowpass next
    fnq=(fs/2);  % Nyquist frequency
    Wn=[higher/fnq];    % butterworth bandpass non-dimensional frequency
    [b,a]=butter(order_highcut,Wn,'low'); % construct the filter
    data=filtfilt(b,a,data); % zero phase filter the data
    if plot_f
        figure
        freqz(b,a);
    end
end
return;