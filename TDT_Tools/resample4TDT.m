function DOUT=resample4TDT(DATA, FS, DFS)
%% DESCRIPTION:
%
%   Function to resample data for use with TDT. This is often useful if
%   sampling rates do not match between data loaded from WAV files and TDT
%   sampling rates. Method invoked is interp1, which works with fractional
%   sampling rates. CWB would prefer to use 'resample', but it only works
%   with integer samping rates. 
%
% INPUT:
%
%   DATA:   NxC matrix, where N is the number of time points and C is the
%           number of data columns (typically the number of channels).
%   FS:     double, TDT sampling rate (e.g., FS=RP.GetSFreq;); 
%   DFS:    double, native sampling rate of DATA. 
%
% OUTPUT:
%
%   DOUT:   MxC matrix, where M is the number of resmpled time points and C
%           is the number of channels.
%   
%   Warnings/errors might also pop up, depending on how thorough CWB is.
%
% Christopher W. Bishop
%   University of Washington
%   02/2014

DOUT=[];
for i=1:size(DATA,2)
    DOUT(:,i)=interp1(1:size(DATA,1), DATA(:,i), 1:DFS/FS:size(DATA,1), 'linear');
end % i=1:size(DATA,2)