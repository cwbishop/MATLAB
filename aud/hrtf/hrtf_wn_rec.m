function hrtf_wn_rec(source,eventdata)
% DESCRIPTION:
%   Record a white-noise stimulus through two inner ear microphones.  
global H rds;

loc=get(H.loc,'value');

%% RECORD
rec=[];
putdata(H.ao,[rds.ref zeros(length(rds.ref),1)]);
start(H.ai)
start(H.ao)
rec(:,:)=getdata(H.ai);

%% DETERMINE RELEVANT PORTION OF RECORDING
% Since there is a delay between the time the sound is played until when it
% is recorded, there is irrelvant information in the recording that may
% impair our ability to estimate a subject's HRTF.  Here, the relevant
% portion of the recording is extracted by finding the peak of the
% cross-correlogram (xcorr).  Of course this is an estimate, but should
% disgard much of the "crap" (e.g., extra silence).
for ch=1:2 
    [y,i]=max(xcorr(rds.ref,rec(:,ch)));
    chOffset(ch)=length(rec)-i;
end

% CB: Not clear to me why anything should be subtracted.  What's with this
% line? It shouldn't matter provided the same value is subtracted
% from both channels (i.e., temporal alignment maintained).
offset=min(chOffset)-40;

% Remove the mean value from the recordings
rec=rec(offset:offset-1+length(rds.ref),:);
rec=detrend(rec,'constant'); 

%% CALCULATE ITD and ILD
% ITD Estimated by calculating the difference in peaks in the
% cross-correlogram between the two channels and converting from samples to
% time.
%
% ILD Estimated by calculating the difference in RMS power between the two
% channels in decibels (dB, 20*log10(RMS(ch1)/RMS(ch2))).
rds.itd(loc)=diff(chOffset)/rds.fs*10^6;

%% Why the bejeebus are we normalizing BEFORE we calculate the HRTF?  I
%% don't think this is necessary.
rds.rec(:,:,loc)=rec; % Added by CB
% rds.rec(:,:,loc)=(rec./max(max(abs(rec))))*.5; % Commented CB

rec_rms=rms(squeeze(rds.rec(:,:,loc)));
rds.ild(loc)=20*log10(rec_rms(1)/rec_rms(2));

%% Update the display to show results of rec
hrtf_update();