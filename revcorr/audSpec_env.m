function [envl, time_stamps, frequencies]=audSpec_env(filename,Fs_Out,numBnds)

% The function produces the auditory spectrogram envelope in dB from a .wav
% file.
% The auditory model employed is multiresolution spectro-temporal analysis http://asadl.org/jasa/resource/1/jasman/v118/i2/p887_s1
% The script is modified from N. Ding 2012 [gahding@umd.edu]
% by F. Cervantes Constantino 2012,2013 [fcc@umd.edu]
% and others in the Simon group.
% http://www.isr.umd.edu/Labs/CSSL/

%filename: A string in 'myDir/mySound.wav' format

%Fs_Out: The output sampling frequency. Default is 200 Hz

%numBnds: The desired number of frequency bands in the envelope representation.
%Integer must be in the range [1,2^7]. If not of the form 2^m, then
%highest bandwidth is residual from all other bandwiths of size 2^(7-n)
%quarter tone. Default is 2^5

%envl: A 2 cell array containing each a NxT matrix representing the
%auditory spectrogram envelope, per stereo channel
%N=numBnds ; T=number of samples at Fs_Out

%Last revision: 2 August 2013

if nargin<3; numBnds=2^5; end
if nargin<2; Fs_Out=200; end
if nargin<1; error('Not enough arguments.'); end

%% Generate auditory spectrograms
loadload;
[stim  Fs_In] = audioread(filename);

% CWB removed this resampling line. He *thinks* this is done to set the
% Nyquist to 4 kHz, but the stimuli we are using have information well
% above that. 8000 is a classic case of a "magic number". 
%
% Actually, the data are resampled so the "-1" parameter in the call to
% wav2aud below is valid. Seems awfully restrictive. But do this as is
% until CWB has time to rework these functions to be more flexible. 
stim=resample(stim,8000,Fs_In);

x1 = stim(:,1); 
try x2 = stim(:,2);
catch x2=x1;
end

% wav2aud estimates the spectrogram
v1 = wav2aud(x1,[5 8 -2 -1]);
v2 = wav2aud(x2,[5 8 -2 -1]);

% Convert to decibel scale. 
v1 = 20*log10(v1+1); v2 = 20*log10(v2+1);
clear x*

%% Obtain envelopes at coarser spectral resolution
envl = cell(1,2);
env1=[];env2=[];
narBndFact = floor((2^7)/numBnds);
for i = 0:numBnds-1;
    if (numBnds * narBndFact ~= size(v1,2)) && (i == numBnds-1)
        env1=[env1 ; mean(v1(:,1+(i*narBndFact):end)')];
        env2=[env2 ; mean(v2(:,1+(i*narBndFact):end)')];
    else
        env1=[env1 ; mean(v1(:,1+(i*narBndFact):(i+1)*narBndFact)')];
        env2=[env2 ; mean(v2(:,1+(i*narBndFact):(i+1)*narBndFact)')];
    end
end

% Resample the envelope to Fs_Out
%   Why is the last input (the current sampling rate) set to 200? The data
%   ARE resampled to 200 Hz at some point, but CWB can't figure out where.
%   Must be in wav2aud, but I can't find the line(s) that do (does) it.
envl{1}=resample(env1,Fs_Out, 200);
envl{2}=resample(env2,Fs_Out, 200);