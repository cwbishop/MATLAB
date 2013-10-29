function [Hdw, d]=make_confon_filter(a, f, Fo)
% DESCRIPTION:
%   
%   Code used to estimate transfer function from MRCONFON headphones.  Run
%   this function from the directory containing your recordings.
%
% INPUT:
%
%   Fo: string, full path to where you want the matfile written. Defaults
%   to 'C:\Documents and Settings\cwbishop\My
%   Documents\matlab\aeq_test\filters\cfilt.mat'
%   a:  double, amplitude of output source file.
%
% OUTPUT:
%
%   cfilt.mat:  matfile containing Hdw and d.
%   Hdw:        filter for each channel
%   d:          filter design structure for each channel.
%
% Bishop, Chris Miller Lab 2009

%% VARIABLE CHECK
if ~exist('f', 'var') || isempty(f), f=round(logspace(log10(20),log10(20000),31)); end

%% LOAD OPTICAL MICROPHONE TRANSFER FUNCTION.
%   The function is inverted, so adding it to deBR and deBL corrects for
%   the microphone transfer function.
load('C:\Documents and Settings\cwbishop\My Documents\matlab\aeq_test\filters\OPT_MIC.mat', 'OptdeB');

%% CALCULATE decibel levels are each frequency for each channel.
[deB]=confon_test(pwd, a, f);
deBL=deB(:,1,1); deBR=deB(:,1,2); clear deB;

%% CORRECT FOR OPTICAL MICROPHONE.
deBR=deBR+OptdeB';
deBL=deBL+OptdeB';

%% DIVIDE ALL decibel LEVELS BY 2
%   Later functions use filtfilt, which filters every file twice, so we
%   have to cut the filter dB levels in half.
% deBR=deBR./2;
% deBL=deBL./2;

%% SHIFT decibel LEVELS SO MAXIMUM IS 0 dB. 
%   This ensures that we won't make the sounds "louder" and introduce some
%   crazy clipping.
m=max(max(([deBL deBR])));
deBL=deBL+(-1*m);
deBR=deBR+(-1*m);

%% CONVERT TO AMPLITUDE FOR ARBITRARY MAGNITUDE FILTER DESIGN
AmpL=10.^(deBL./20);
AmpR=10.^(deBR./20);

%% DESIGN FILTERS
%   Channel (1) is the LEFT channel
f=round(logspace(log10(20),log10(20000),31));
f=f./22050; % 22050 = Nyquist for 44100 Hz sampling rate. If you want a different sampling rate, change this.  Everything else should be the same.
d(1)=fdesign.arbmag;
d.FilterOrder=1000;
d.Frequencies=[0 f 1];
d.Amplitudes=[AmpL(1) AmpL' AmpL(end)];
Hdw(1)=design(d(1));

% Repeat for right channel.
d(2)=fdesign.arbmag;
d(2).FilterOrder=1000;
d(2).Frequencies=[0 f 1];
d(2).Amplitudes=[AmpR(1) AmpR' AmpR(end)];
Hdw(2)=design(d(2));

%% SAVE FILTER INFORMATION
if ~exist('Fo') || isempty(Fo)
    Fo=['C:\Documents and Settings\cwbishop\My Documents\matlab\aeq_test\filters\cfilt_fftfilt_' num2str(a) '.mat'];
end 

save(Fo, 'Hdw', 'd');