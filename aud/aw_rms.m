function [out x] =aw_rms(x,fs,plotFlag)
%produce an a-weighted rms

if ~exist('plotFlag','var') || isempty(plotFlag)
    plotFlag = 0;
end

f=[0:10:fs/2];
n=200;
a=filterA(f,plotFlag);

%normalize frequency to nyquist 
f=2*f/fs;

Hdw=design(fdesign.arbmag(n,f,a));

x=fftfilt(Hdw.Numerator,x);

out=rms(x);
