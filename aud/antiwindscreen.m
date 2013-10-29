function [TF,IR] = antiwindscreen(wavAlone,wavScreened);
%Returns a impulse response for a transfer function between two recordings.
%Written to remove the effects of a windscreen on a outdoor microphone.
%Written for Diane Blackwood and Jessica Blickley by Kevin Hill 12/4/06
%
%IR = antiwindscreen(fs)
%
%IR - The impulse response which will be convolved with a time series to
%remove the effects of the windscreen
%fs - sampleing frequency of the sound card

%%%%%Load recordings from .wav files%%%%%
%note, assumed same sampleing frequency, and roughly same length.
recAlone=wavread(wavAlone);
recScreened=wavread(wavScreened);

%%%%%Align the recordings by cross correlation%%%%%
xcors=xcorr(recAlone,recScreened);
xcorsIndx=find(xcors_temp==max(xcors_temp));
timingDif=xcorsIndx-recSamps;

if timingDif>0
    alone=recAlone(timingDif+1:end);
    screened=recScreened(1:length(alone));
else
    screened=recScreened(abs(timingDif)+1:end);
    alone=recAlone(1:length(screened));
end

%%%%%Compute Transfer Function%%%%%
fftAlone=fft(alone);
fftScreened=fft(screened);

%With Head Related Transfer Functions, we have found that smoothing the
%frequency magnitute helps achieve more consistent results. You might have
%to adjust the second value or comment out the line to achieve best results
[b,a]=butter(2,.4);
magAlone=max(filtfilt(b,a,abs(fftAlone)),.05); 
magScreened=max(filtfilt(b,a,abs(fftScreened)),.05);
%%version without smoothing
%magAlone=abs(fftAlone);
%magScreened=max(fftScreened);

%Also need phase
phAlone=angle(fftAlone);
phScreened=angle(fftScreened);

%Create HRTF by dividing power and subtracting phase of ref, get an HRIR by IFFT
TFmag=(magAlone./magScreened);
TFph=phAlone-phScreened;
TF= TFmag.*cos(TFph)+ sqrt(-1)* TFmag.*sin(TFph);
IR= ifft(TF,'symmetric');

%%%%%Notes%%%%%
%In our setup for Head Related Transfer functions, we have found it
%benificial to bandpass the HRTF by createing a window vector in the
%frequency domain. Here is the code we used which could be applied here
%before or after filtering the fft
%
%%create band pass for freq domain
%F = fs*[1:length(fftRecs)]/length(fftRecs); 
%nqsamp = length(F)/2;
%lowWidth = max(find(F(1:nqsamp)<l_hz));
%if ~exist('lowWidth'), lowWidth=1;end
%limitWidth = nqsamp-min(find(F(1:nqsamp)>limit_hz));
%highWidth = nqsamp-min(find(F(1:nqsamp)>h_hz))-limitWidth;
%lowFilt = blackman(2*lowWidth);
%highFilt = blackman(2*highWidth);
%gap = nqsamp-lowWidth-highWidth-limitWidth;
%win = [lowFilt(1:lowWidth);ones(gap,1);highFilt(highWidth+1:end);zeros(limitWidth,1)];
%win = [win;flipud(win)];