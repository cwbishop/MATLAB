function [envelope, center_frequencies]=audSpec_env(audio_track, varargin)
%% DESCRIPTION:
%
%   This function produces an auditory spectrogram envelope (in dB). 
%
% INPUT:
%
%   audio_track:    can be any (auditory) data type supported by
%                   SIN_loaddata. Typically this will be a file name to an
%                   audio file or the time series itself. 
%
% Parameters:
%
%   'output_fs':    output sampling rate in Hz. 
%
%   'n_frequency_bands':    number of frequency bands to use in envelope
%                           estimation. Must be in range of [1 2^7]. If not 
%                           of the form 2^m, then highest bandwidth is 
%                           residual from all other bandwiths of size 
%                           2^(7-n) quarter tone. (no default)
%
%   'input_fs': input sampling rate in Hz. Required if audio_track is a
%               time series. 
%
% OUTPUT:
%
%   envelope:   A C-element cell array, where C is the number of channels
%               in audio_track. Each element of envelope is an NxT matrix,
%               where N is the number of frequency bins and T is the number
%               of time points.
%
%   center_frequencies: the center freqencies of the N frequency bands. 
%
% Provided by Simon Lab UMD
%   Revisions and mods by Chris Bishop, UW/UCD 12/2014

%% LOAD PARAMETERS
opts = varargin2struct(varargin{:});

%% SET DEFAULTS
if ~isfield(opts, 'input_fs'), opts.input_fs = []; end

%% GENERATE AUDIO SPECTROGRAM
loadload;
[audio_track, input_fs] = SIN_loaddata(audio_track, 'fs', opts.input_fs); 

% CWB removed this resampling line. He *thinks* this is done to set the
% Nyquist to 4 kHz, but the stimuli we are using have information well
% above that. 8000 is a classic case of a "magic number". 
%
% Actually, the data are resampled so the "-1" parameter in the call to
% wav2aud below is valid. Seems awfully restrictive. But do this as is
% until CWB has time to rework these functions to be more flexible. 
stim = resample(audio_track, 8000, input_fs);

x1 = stim(:,1); 
try x2 = stim(:,2);
catch x2 = x1;
end

% wav2aud estimates the spectrogram
%   Also collect the center frequencies of the estimated bands. This will
%   be used below to estimate frequency bin centers for the "coarser"
%   spectral resolution. 
[v1, CF, FS_SCALE] = wav2aud(x1, [5 8 -2 -1]);
v2 = wav2aud(x2,[5 8 -2 -1]);

% Compute output FS
FS = 8000 .* FS_SCALE;

% Convert to decibel scale. 
v1 = 20*log10(v1+1); v2 = 20*log10(v2+1);
clear x*

%% Obtain envelopes at coarser spectral resolution
envelope = cell(1,2);
env1=[];env2=[];
narBndFact = floor((2^7)/opts.n_frequency_bands);
for i = 0:opts.n_frequency_bands-1;
    if (opts.n_frequency_bands * narBndFact ~= size(v1,2)) && (i == opts.n_frequency_bands-1)
        mask = 1+(i*narBndFact):size(v1,2);
%         env1=[env1 ; mean(v1(:,1+(i*narBndFact):end)')];
%         env2=[env2 ; mean(v2(:,1+(i*narBndFact):end)')];        
    else
        mask = 1+(i*narBndFact):(i+1)*narBndFact;
%         env1=[env1 ; mean(v1(:,1+(i*narBndFact):(i+1)*narBndFact)')];
%         env2=[env2 ; mean(v2(:,1+(i*narBndFact):(i+1)*narBndFact)')];
    end
    
    % Average over the specified frequency bands
    env1 = [env1; mean(v1(:,mask)')];
    env2 = [env2; mean(v2(:,mask)')]; 
    
    % New center frequencies are the average of the frequency bins we
    % averaged over.
    center_frequencies(i+1,1) = mean(CF(mask));     
    
end % for i=0:...

% Resample the envelope to Fs_Out
%   Why is the last input (the current sampling rate) set to 200? The data
%   ARE resampled to 200 Hz at some point, but CWB can't figure out where.
%   Must be in wav2aud, but I can't find the line(s) that do (does) it.
envelope{1}=resample(env1, opts.output_fs, FS);
envelope{2}=resample(env2, opts.output_fs, FS);