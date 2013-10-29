function [out,fs] = takegata_stims(bf,harmdbvec,outrms,dur,rampdur,gapdur,gaprampdur,fs)
%This is an attempt to remake stimuli like those used by the Takegata group
%to elicit MNNs. It is capable of making both the standards, and 4 of 5
%deviants (no spatial yet) used in the study:
%
%Naatanen, R., S. Pakarinen, et al. (2004). "The mismatch negativity (MMN):
%towards the optimal paradigm." Clin Neurophysiol 115(1): 140-144.
%
%Defaults for all parameters follow those of the study.
%
%function [out,fs] = takegata_stims(bf,harmdbvec,outrms,dur,rampdur,gapdur,gaprampdur,fs)
%
%INPUTS:
% bf         - base frequency for the sounds
% harmdbvec  - a vector describing the relative dB's of harmonics (as many 
%              are used as are enumerated)
% outrms     - rms of the output, can be used to calculate relative dB between two stims
% dur        - duration of the stims in seconds
% rampdur    - length of the linear amplitude ramp at edges in sec
% gapdur     - length of the gap in seconds placed in the middle of the stims
% gaprampdur - length of the linear amplitude ramp at edges in sec
% fs         - sampling frequency
%
%OUTPUTS:
% out - the output sound vector
% fs  - the output sampling frequency, just in case there was any confusion


%defaults for all of the parameters
if ~exist('bf','var') || isempty(bf)
    bf=500; %base frequency
end
if ~exist('harmdbvec','var') || isempty(harmdbvec)
    harmdbvec=[-3 -6]; %a vector describing the relative dB's of harmonics (as many are used as are enumerated)
end
if ~exist('outrms','var') || isempty(outrms)
    outrms=.25; 
end
if ~exist('gapdur','var') || isempty(gapdur)
    gapdur=0; %
end
if ~exist('dur','var') || isempty(dur)
    dur=.075; %
end
if ~exist('rampdur','var') || isempty(rampdur)
    rampdur=.005; %
end
if ~exist('gapramp','var') || isempty(gaprampdur)
    gaprampdur=.001; %
end
if ~exist('fs','var') || isempty(fs)
    fs=48000; %sampling frequency
end

out = sin_gen(bf,dur,fs);

%set up harmonics
baserms = rms(out);
for h=1:length(harmdbvec)
    harm = sin_gen(bf*(h+1),dur,fs);
    harm = harm * 10^(harmdbvec(h)/20)*baserms/rms(harm);
    out=out+harm;
end

%set total rms (note this is before ramps or gaps)
out = out * outrms/rms(out);

if max(abs(out(:))) > .99
    error('Error, desired output rms (%d) would cause sound to clip, try an output rms of %d', outrms, outrms * .95/max(abs(out(:))));
end

ramp=linspace(0,1,fs*rampdur);
vec=ones(dur*fs,1);
vec(1:length(ramp))=ramp;
vec(end:-1:end-length(ramp)+1)=ramp;

if gapdur
    gapramp=linspace(1,0,fs*gaprampdur);
    idx=floor(length(out)/2-(fs*gapdur/2)):floor(length(out)/2 + (fs*gapdur/2));
    gap=zeros(length(idx),1);
    gap(1:length(gapramp))=gapramp;
    gap(end:-1:end-length(gapramp)+1)=gapramp;
    vec(idx)=gap;
end

out=out.*vec;