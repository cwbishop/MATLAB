function [out x]= cw_rms(x,fs);
%produce an c-weighted rms

f=[0:10:fs/2];
n=200;
a=filterC(f,1);

%normalize frequency to nyquist 
f=2*f/fs;

Hdw=design(fdesign.arbmag(n,f,a));

x=fftfilt(Hdw.Numerator,x);

out=rms(x);
