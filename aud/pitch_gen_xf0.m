function out = pitch_gen_xf0(F0, Fs, Ff, t, fs)
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


amp=1;
hz= Fs;
i = 0;

out=zeros(t*fs,1);

while hz <= (Ff)
    ph = rand(1,1) * 2;
    out=out+(amp*sin_gen(hz,t,fs,ph)); 
    hz=hz+F0;
    %amp=F0/hz; %Uncomment to make power spectrum 1/f
    
    i = i + 1;
end
disp(i)
out = out./max(abs(out));