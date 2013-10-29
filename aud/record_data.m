function [RDATA RDATAF RDATAC RDATAFC]=record_data(IN, OUT, DATA, FS, T, HPASS, CLEAN)
%% DESCRIPTION:
%
%   Record arbitrary data from an analog INPUT device.  Several options are
%   available, including recording a specific sound played through an
%   arbitrary analog output device.
%
%   The advantage of this code over other functions in the lab (e.g.
%   rec_vec) is that it uses manual triggering to get near simultaneous
%   playback and recording of data.  
%
%   Much of the code and ideas were gleaned from MSPE_cal.m written by
%   Bishop, CW.
%
% INPUT:
%
%   IN:     string, name of input device (e.g. 'Fireface 800 Analog (3+4)')
%   OUT:    string, name of output device (e.g. 'Gina3G 1-2 Digital Out')
%   DATA:   double array, data to present from output device. This can be
%           either one or two columns.
%   FS:     double, sampling rate (e.g. 96000)
%   T:      double, total recording time (seconds).  Notice that the
%           recording time is set to slightly longer than the DATA input if
%           DATA is defined. If DATA is not defined, then T must be
%           specified.  Alternatively, if T is longer than DATA, the
%           recording will last for T seconds. (default is duration DATA +
%           some short amount of time (currently 1.5 msec)).
%   HPASS:  double, cutoff for highpass filter (Hz) (e.g. 10)
%   CLEAN:  double, cutoff value used to remove silence before and after
%           recording.  (default=0, so nothing done).
%
% OUTPUT:
% 
%   RDATA:      Nx2 array, raw recording from INPUT device.
%   RDATAF:     Nx2 array, highpass filtered recording
%   RDATAC:     Nx2 array, cleaned recording. Data smaller than CLEAN
%               coefficient are removed from the beginning and end of the
%               recorded data
%   RDATAFC:    Nx2 array, highpass filtered and cleaned data.
%
% Bishop, CW
%   Miller Lab UC Davis 2010

%% SET DEFAULTS
%
%   The duration of the recording might be a little confusing.  The basic
%   idea is that we record long enough to record DATA (+ some short amount
%   of time to ensure we catch everything) OR we record for a set amount of
%   T(ime).  If the requested recording duration (T) is less than DATA, the
%   recording is extended to capture all of DATA.  This is a feature, not a
%   bug, but it might annoy some users.  To this CB says "write your own
%   code."
%
%   If DATA is a monochannel sound, copy it over to create diotic stimuli.
if ~exist('FS', 'var') || isempty(FS), FS=96000; end
if ~exist('OUT', 'var') || isempty(OUT), OUT=''; end
if ~exist('CLEAN', 'var') || isempty(CLEAN), CLEAN=0; end
if exist('DATA', 'var') && size(DATA,2)==1, DATA=DATA*[1 1]; end % make sure we have two channels of output.
if (exist('DATA', 'var') && ~isempty(DATA)) && (~exist('T', 'var') || isempty(T) || T*FS < length(DATA)), T=(length(DATA))/FS + 0.003; warning('T adjusted to match stimulus duration'); end % make sure recording isn't too short to see all of DATA
if ~exist('T', 'var'), error('DATA nor T(ime) are defined. I need something to work with here, stud.'); end % make sure we have time defined.

%% CLEAR VARIABLES
%   Must clear out DAQ or we'll get all kinds of silly errors.  Still get a
%   few even with this, but very infrequent and idiosyncratic.  It's the
%   best we can do, I think.
clear Ai Ao
delete(daqfind);
clear hw;

%% GRAB HARDWARE INFORMATION
%   Slightly different way of grabbing information.  winsoundhwinfo can be
%   downloaded from MATLAB CENTRAL.
hw=winsoundhwinfo;

%% SETUP INPUT DEVICE
%   Use string matching to determine INPUT device.  Set trigger type to
%   manual for consistent start times of INPUT and OUTPUT devices.  
ai=strmatch(IN,hw.InputBoardNames,'exact')-1;
Ai=analoginput('winsound', ai); 
addchannel(Ai, 1:2);
set(Ai, 'StandardSampleRates', 'Off');
set(Ai, 'SampleRate', FS);
set(Ai,'SamplesPerTrigger',T*get(Ai, 'SampleRate'));
set(Ai,'TriggerType','Manual')

%% SETUP OUTPUT DEVICE OBJECT
%   Only setup an output if user wants to play a sound.  Play both
%   channels.
if ~isempty(OUT)
    ao=strmatch(OUT,hw.OutputBoardNames,'exact')-1;
    Ao=analogoutput('winsound', ao);
    addchannel(Ao,1:2);
    set(Ao,'StandardSampleRates','Off')
    set(Ao,'SampleRate',FS);
    % set(Ao, 'BitsPerSample', 16);
    set( Ao,'TriggerType','Manual')
    putdata(Ao,DATA);
end % if ~isempty

%% PLAY/RECORD SOUND
%   Manually start devices.
if exist('Ao', 'var')
    start([Ao Ai]);
    trigger([Ai Ao]);
else
    start([Ai]); 
    trigger([Ai]);
end % if 

%% RETRIEVE RECORDED SOUND
RDATA = getdata(Ai); 
clear Ai Ao
delete(daqfind); 

%% HIGH-PASS FILTER DATA
%   Only filter if HPASS is specified
if exist('HPASS', 'var') && ~isempty(HPASS)
    RDATAF=highpass(RDATA,HPASS,FS); 
else
    RDATAF=RDATA; 
end % if exist('FLTR'...

%% CLEAN DATA
%   This proved useful for getting rid of leading or lagging zeros (or
%   small values) that are typically at the beginning and end of
%   recordings.
if CLEAN~=0
    RDATAC=RDATA(find(abs(RDATA)>=CLEAN, 1, 'first') : find(abs(RDATA)>=CLEAN, 1, 'last'));
    RDATAFC=RDATAF(find(abs(RDATAF)>=CLEAN, 1, 'first') : find(abs(RDATAF)>=CLEAN, 1, 'last'));
else
    RDATAC=[];
    RDATAFC=[];
end % if CLEAN