function out = pitch_gen(F0, t, fs, rndPh)
%out = pitch_gen(F0,t,fs,rndPh);
%
%Creates a complex pitch with F0 of F0 and length of t in seconds. The
%power spectrum envelope is flat
%
%INPUTS:
%F0    - Fundamental frequency of the pitch
%t     - Time in seconds of output
%fs    - Sampling frequency. Defaults to 44100.
%rndPh - Binary flag. If set, the phase of the F0 and harmoics is
%        randomized

if ~exist('rndPh') || isempty(rndPh)
    rndPh=0;
end
if ~exist('fs') || isempty(fs)
    fs=44100;
end

amp=1;
hz=F0;
ph=0;

out=zeros(t*fs,1);

while hz < (fs/2)
    if rndPh, ph=(2*pi*rand(1)); end
    out=out+(amp*sin_gen(hz,t,fs)); 
    
    hz=hz+F0;
    %amp=F0/hz; %Uncomment to make power spectrum 1/f
    
    
end

out = out./max(abs(out));