%%%Function to output the envelope of a signal
%First, you can bandpass the input frequency (slower, shigher)
%Then, you can bandpass the Hilbert Transform envelope (elower, ehigher) 
% x = signal
%slower =  the highpass cutoff (lower value) for the frequency within the signal 
%shigher =  the highpass cutoff (lower value) for the frequency within the signal 
%elower = the highpass cutoff (lower value) for the envelope signal
%ehigher = the lowpass cutoff (higher value) for the envelope signal
%fs = sampling rate of the signal

function [envel fsig absig] = elope(x,slower,shigher,elower,ehigher,fs)


fsig = butterfilt(x,slower,shigher,fs,3,3);

absig = abs(hilbert(fsig));
%absig = 20*log10(absig); 


envel = butterfilt(absig,elower,ehigher,fs,3,3);



