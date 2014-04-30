function [Y, FS]=portaudio_playrec(IN, OUT, X, FS, T, varargin)
%% DESCRIPTION:
%
%   Function for basic playback and recording using the PsychPortAudio
%   driver packaged with PsychToolBox 3. 
%
%   Can be used to record data for arbitrary lengths of time or perform
%   (near) simultaneous playback/recording. 
%
%   This function is a close descendent of record_data.m written by CWB in
%   2010. 
% 
%   Currently uses a 10 second recording buffer that is emptied every ~5 s.
%   
% INPUT:
%
%   IN: recording device information. Can be a string or integer index into
%       return from PsychPortAudio('GetDevices'). Strings will be matched
%       to the 'DeviceName' field returned from PsychPortAudio. Make sure
%       the string matches perfectly, typos, missing characters and all.
%
%   OUT:    playback device information. Identical to "IN", but for sound
%           playback.
%
%   X:  NxC data matrix, where N is the number of samples and C is the
%       number of channels in the sound playback device. Note that by
%       default the output device will present sound from all available
%       channels. Add zeros to channels you do not want sound to play from.
%
%       Alternatively, X can be the path to a wav file or other data type
%       supported by AA_loaddata. 
%
%   FS: sampling rate for sound playback and recording. (default=44100)
% 
%   T:  If X is empty and T is provided, records for a specified period of
%       time in seconds. 
%
%       The actual recording time will be approximate, but should always be 
%       as long or longer than the requested recording duration.
%       
%       XXX Devel XXX Set T to Inf for continuous recordings. XXX 
%
%   Parameters:
%
%       'devicetype':   integer, specifying the preferred device type. This
%                       is often useful if the user wants to select a
%                       single physical device and soud playback
%                       driver/API. Here are the Windows specific flags.
%                       Values in brackets specify order of quality and
%                       latency (1=best, 4=worst). 
%                      
%                           1: Windows/DirectSound [3]
%                           2: Windows/MME [4]
%                           3: Windows/ASIO [1]
%                           11: Windows/WDMKS [2]
%                           13: Windows/WASAPI [2] 
%
%                       For more information and additional device types,
%                       see http://docs.psychtoolbox.org/GetDevices
%                           
% OUTPUT:
%
%   Y:  recorded time series
%   FS: sampling rate of recorded time series
%
% Christopher W. Bishop
%   University of Washington
%   4/14

%% INPUT CHECKS AND DEFAULTS
if ~exist('IN', 'var'); IN=[]; end 
if ~exist('OUT', 'var'); OUT=[]; end 
if ~exist('X', 'var'); X=[]; end 
if ~exist('FS', 'var') || isempty(FS); FS=44100; end 
if ~exist('IN', 'var'); IN=[]; end 
if ~exist('T', 'var'); T=[]; end 

% Convert parameters to structure
if length(varargin)>1
    p=struct(varargin{:}); 
elseif length(varargin)==1
    p=varargin{1};
elseif isempty(varargin)
    p=struct();     
end %

%% DATA PLAYBACK
%   Load time series for playback, massage into expected shape
if ~isempty(X)
    [X, fs]=AA_loaddata(X); 
    % Resample output to match overall sample rate
    %   Will only be done if data are loaded from a WAV file and the sampling
    %   rates do not match. 
    if ~isempty(fs) && (fs~=FS)
        X=resample(X, FS, fs); 
    end % if ~isempty(fs)
    
end % if ~isempty(X)

%% INITIALIZE PORT AUDIO DEVICES
InitializePsychSound;

%% GET PLAYBACK AND RECORDING DEVICE NUMBER
%   Will return the index for the playback and recording devices. 
[pstruct]=portaudio_GetDevice(OUT, p);
[rstruct]=portaudio_GetDevice(IN, p); 

%% ERROR CHECKS FOR DATA PLAYBACK
%   - Make sure we have data for all playback channels

% Make sure we have all the channel data we need to playback.
%   If we don't have enough channels, throw an error (for now). 
if ~isempty(X) && size(X,2)~=pstruct.NrOutputChannels
    error(['Playback time series must have ' num2str(pstruct.NrOutputChannels) ' channels.']);
end % if ~isempty(X) && size(X ...

%% PREPARE FOR PLAY/REC

% Get recording handle
% pahandle = PsychPortAudio('Open', 2, 2, 0, freq, 2);
rhand = PsychPortAudio('Open', rstruct.DeviceIndex, 2, 0, FS, rstruct.NrInputChannels); 

% Initialize and fill playback buffer
if ~isempty(X)
    phand = PsychPortAudio('Open', pstruct.DeviceIndex, 1, 0, FS, pstruct.NrOutputChannels); 
    PsychPortAudio('FillBuffer', phand, X');
end % if ~isempty(X)

% Allocate Recording Buffer
%   10 second buffer by default
PsychPortAudio('GetAudioData', rhand, 10); 

% Start recording
%   Wait for recording to start (for real) before continuing. Helps ensure
%   recording time (I think). 
PsychPortAudio('Start', rhand, [], [], 1); 

% Start Playback, if requested
Y=[]; % Recorded data
if exist('phand', 'var')
    
    PsychPortAudio('Start', phand);
    
    start_time=GetSecs; 
    
    % Start soundplayback
    pstatus=PsychPortAudio('GetStatus', phand);
    
    % Now, wait for soundplayback to start
    while ~pstatus.Active, pstatus=PsychPortAudio('GetStatus', phand); end 
    
    % Now, wait for soundplayback to finish.
    %   While playback is happening, empty the recording buffer
    %   periodically. 
    while pstatus.Active
        
        if GetSecs - start_time > 5
            start_time=GetSecs; 
            y=PsychPortAudio('GetAudioData', rhand);            
            Y=[Y; y'];            
        end % if start_time ...
        
        pstatus=PsychPortAudio('GetStatus', phand); 
    end %
    
    % Grab whatever is left over in the recording buffer
    y=PsychPortAudio('GetAudioData', rhand);            
    Y=[Y; y'];    
    
elseif ~isempty(T)
    
    % If we are recording for set amount of time. 
    START_TIME=GetSecs; 
    st=START_TIME;
    
    % Record for T seconds
    while GetSecs -  START_TIME < T
        
        % Empty buffer every ~ 5 s
        if GetSecs - st > 5     
            st=GetSecs; 
            y=PsychPortAudio('GetAudioData', rhand);            
            Y=[Y; y'];            
        end % if start_time ...       
        
    end % while GetSecs-START_TIME ...    

    % Grab whatever is left over in the recording buffer
    y=PsychPortAudio('GetAudioData', rhand);            
    Y=[Y; y'];            
    
end % exist('phand ...

% Close Devices
PsychPortAudio('Close'); 