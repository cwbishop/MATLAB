function y = spect_filter(x, b, varargin)
%% DESCRIPTION:
%
%   This function convolves a spectrally decomposed signal with it's
%   corresponding filter coefficients.
%
% INPUT:
%
%   x:  NxTxM matrix containing the auditory representations of the
%acoustic stimuli. N=number of frequency channels ; T=number of samples ;
%M=number of experimental conditions
%
%   b:  NxLxM, where L is the number of filter taps
%
% OUTPUT:
%
%   y:  filtered and summed signal
%
% Christopher W. Bishop
%   University of Washington
%   12/14

% Filter each frequency band
y = []; 
for m=1:size(x,3)
    filter_coefficients = b{m};
    signal = x(:,:,m); 
    for i=1:size(signal,1)
    
        y(i,:,m) = filter(filter_coefficients, 1, signal(i,:)); 
    
    end % for i=1:size(x,1)
end % for m=1:size(x,3)

% Sum over frequency bands
y = squeeze(sum(y,1)); 
