function [hds BASE] = hrtf_compute(rds, opts, n, ref)
% DESCRIPTION:
%
%   Compute an individual's Head Related Transfer Function (HRTF).  All
%   recording coordinated through a GUI initialized in hrtf.m.  
%   
% INPUT:
%
%   rds:    Structure with recording information, see hrtf.m for field 
%           details (hds has similar fields, described below).
%   opts:   char array, each row is an option. Options include
%           SM: logorithmic smoothing
%           NR: RMS normalization to arbitrary value.
%           MF: Compensate for Inner Ear Mic Transfer Functions.
%   n:      integer, the length of the HRIR returned (returns entire HRIR
%           by default);
%   ref:    n x 2 double array
%           Alternative reference WAVEFORM.  If you want to create HRTF
%           relative to something other than the recording in the rds 
%           structure, then include the WAVEFORM here.
%           
% OUTPUT:
%
%   hds:    structure with HRTF information.
%       .sub:       string, subject ID
%       .hrir:      time representation of HRTF
%       .hrtf:      frequency representation of HRIR
%       .thetaVec:  double array, recorded angles
%       .fs:        integer, sampling frequency of HRIR
%           NOTE: the FS of the HRIR and the source MUST match or things
%           won't work right (see hrtf_compute for details).
%
% Hill, Kevin (original version)
% Bishop, Chris (modifications listed below)
%
% 090126 CB:    
%   -Added detailed comments to all key segments of code.  
%   -Fixed a small bug in the normalization routine (filtered backwards), 
%   but this did little to improve externalization if anything at all.
%   -Tried applying SPEAKER and MIC transfer functions to recordings.
% 090204 CB:
%   -Added optional inputs for SMOOTHING, NORMALIZATION, and applying
%   MICROPHONE TRANSFER FUNCTIONS.
%       -CB Doesn't recommend using NORMALIZATION or MIC. TRANS FUNC, and
%       is indifferent to SMOOTHING.  That's why they are all optional
%       processing steps.
% 090908 CWB
%   -Changed NORMALIZATION routine to do something slightly different.
%   Prior to this change, the normalization routine would normalize each
%   subject's HRTF using  a subject specific reference value.  I simply
%   changed this so it normalizes to some arbitrary value that works well
%   with our default system settings.  This is easier than trying to do
%   some sort of study specific normalization later.
%   -Also, the normalization routine interpolates the HRTF at 0 degrees
%   azimuth, provided the sampling is dense enough around midline.  
%   -Normalization routine moved to HRTF_FINISH.m.  Easiest place to put it
%   for large HRTFs.
%
% RECOMMENDATION:
%
%   HRTFs should ideally be measured at all desired angles, but if that is
%   prohibitively large number, linear interpolation is a good alternative.
%   Currently, CB has tried interpolating data from HRTFs sampled every 1,
%   2, 3, and 5 degrees and recommends sampling every 2 degrees.
%
%   Also, CB recommends running the new NORMALIZATION routine (see 090908
%   CWB).  This will ensure you don't blow your subject's ear drums out and
%   will provide another layer of security that your sounds are consistent
%   across subjects.  For this process, you'll want to sample around 0
%   degrees azimuth.
%
%   Finally, during HRTF acquisition, set the DEQ to BYPASS all in-line
%   filters.  During sound playback, apply the AEQ HRTF filter.  This
%   filter was estimated using the DEQ's Auto-EQualization (AEQ) function.
%   To do this, I setup the inner ear microphones in the control room in
%   the approximate position that HRTFs are acquired, and pointed them
%   directly at the speaker.  I (CB) performed the AEQ function for one
%   channel, then the next, averaged the filters, and saved them as AEQ
%   HRTF.  This should roughly correct for any non-linearities in the
%   recording pipeline (i.e., compensate for the speaker and inner-ear
%   microphone transfer functions).
%% LOAD IN FIGURE INFORMATION (H)
global H;
hds.sub=rds.sub;
hds.fs=rds.fs;
hds.thetaVec=rds.thetaVec;

lowHz = 20;
hiHz = 16000;
limitHz = 20000;

%% FOURIER TRANSFORM OF RECORDING
fftRecs=fft(rds.rec);

%% FOURIER TRANSFORM OF REFERENCE
%   If ref included as an input argument, then use this instead of rds.ref.
%   The idea here was to potentially use difference reference waveform with 
%   the microphone and speaker transfer functions included in it to get a
%   better HRTF.  Unfortunately, all attempts by CWB and KH just didn't
%   sound right.
if exist('ref', 'var') && size(ref,1)>0 && size(ref,2)==2
    fftRef=fft(ref);
else
    fftRef=fft([rds.ref rds.ref]); 
end

%% ESTIMATE POWER SPECTRUM
% The absolute value of a complex number is equal to the magnitude (power)
% of the vector.  (sqrt(x^2+y^2), or the length of the hypotenuse of a
% right triangle plotted on real/imaginary axes).
magRecs=abs(fftRecs); 
magRef=abs(fftRef); 

%% ESTIMATE PHASE
% Phase is encoded by the angle formed between the vector and real axis (x,
% abscissa).  ANGLE calculates it automatically because MATLAB is amazing.
phRecs=angle(fftRecs);
phRef=angle(fftRef);

%% CREATE A BAND-PASS FILTER
% Frequency Dim Scalar
F = linspace(0,rds.fs,length(rds.rec))'; 
nqsamp = length(F)/2;
% Find low frequency cutt-off.
lowWidth = max(find(F(1:nqsamp)<lowHz));
if ~exist('lowWidth'), lowWidth=1;end
% Why use limitwidth and hiwidth? I R confused.
limitWidth = nqsamp-min(find(F(1:nqsamp)>limitHz));
hiWidth = nqsamp-min(find(F(1:nqsamp)>hiHz))-limitWidth;
lowFilt = blackman(2*lowWidth);
hiFilt = blackman(2*hiWidth);
gap = nqsamp-lowWidth-hiWidth-limitWidth;
win = [lowFilt(1:lowWidth);ones(gap,1);hiFilt(hiWidth+1:end);zeros(limitWidth,1)];
win = [win;flipud(win)];

fprintf(1,'Computing HRTFs...\n')
%% COMPUTE HRTF
%   Magnitude estimated by dividing magnitude spectra of recording by
%   magnitude spectra of reference (output sound).
%   Phase change relative to reference.
for theta=1:length(rds.thetaVec)
    magHRTF = (magRecs(:,:,theta)./magRef).*[win win];

    %% LOG_SMOOTH HRTF (if SM option set)
    if exist('opts', 'var') && ~isempty(strmatch('SM', opts))
        fprintf(1,['  Log smoothing ' num2str(rds.thetaVec(theta)) ' ... ']);
        tic
        magHRTF = log_smooth(magHRTF(1:end/2,:),F(1:end/2),.02,5);
        magHRTF = [magHRTF;flipud(magHRTF)];
        fprintf(1, [num2str(toc) ' secs\n'])
    end % SMOOTH
    
    %% CALCULATE REAL AND IMAGINARY COMPONENTS
    phHRTF  = phRecs(:,:,theta)-phRef;
    hds.hrtf(:,:,theta) = magHRTF.*cos(phHRTF)+ sqrt(-1)* magHRTF.*sin(phHRTF);
end

%% CREATE HEAD RELATED IMPULSE RESPONSE (HRIR) 
hrir = ifft(hds.hrtf,'symmetric');

%% COMPENSATE FOR MICS?
%   I haven't had good luck getting this to work right.  According to Hill,
%   the best way we've been able to do this is to setup the DEQ with the
%   HRTF settings during HRTF recordings.  Although this works better, CB
%   likes recording the signal as raw as possible and filtering later, that
%   way we have as much information as possible.  Unfortunately, filtering
%   later isn't working out at the moment.
if exist('opts', 'var') && ~isempty(strmatch('MF', opts))
    display(['Applying ' which('mic-filters.mat')]);
    load('mic-filters.mat');
    for z=1:size(hrir,3)
        hrir(:,1,z)=fftfilt(Hdw{1}.Numerator, hrir(:,1,z));
        hrir(:,2,z)=fftfilt(Hdw{2}.Numerator, hrir(:,2,z));
    end %
    clear Hdw;
end % MF

%% TRUNCATE HRIR IF USER DESIRES
%  If the GUI is used for HRTF acquisition, hrirs are truncated to 20000
%  samples by default for speed.
if exist('n', 'var') hrir=hrir(1:n,:); end 
hds.hrir=hrir;

%% FINALIZE AND WRITE
hds.hrtf=fft(hds.hrir);

%% CREATE BASE FILENAME FOR WRITING PURPOSES.
%   Files are not written here, but are passed on to hrtf_finish for
%   writing.
BASE=[];
BASE=[H.subPath rds.sub];
if exist('opts', 'var')
    for z=1:size(opts,1)
        if z==1
            BASE=[BASE '_' deblank(opts(z,:))];
        else
            BASE=[BASE '-' deblank(opts(z,:))];
        end
    end % z
end % exist