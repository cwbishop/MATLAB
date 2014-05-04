function portaudio_adaptiveplay(X, varargin)
%% DESCRIPTION:
%
%   This function is designed to allow (near) real-time modification of
%   sound playback. To do this, the function will accept a function handle
%   to a "checker" function that determins whether or not a change in the
%   audio is required. The function will also accept a "modifier" function
%   that modifies the time series during sound playback. 
%
%   This function (the top-level function) will then handle the transition
%   from one sound state to the next. 
%
% INPUT:
%
%   X:
%
% Parameters:
%
%   'bock_dur':     data block size in seconds. The shorter it is, the
%                   faster the adaptive loop is. The longer it is, the less
%                   likely you are to run into buffering problems. 
%
%   'check':  function handle
%
%   'modify': function handle
%
%   'termination':  function handle for termination conditions. 
%
% OUTPUT:
%
%   XXX
%
% Christopher W. Bishop
%   University of Washington
%   5/14

%% MASSAGE INPUT ARGS
% Convert inputs to structure
%   Users may also pass a parameter structure directly, which makes CWB's
%   life a lot easier. 
if length(varargin)>1
    p=struct(varargin{:}); 
elseif length(varargin)==1
    p=varargin{1};
elseif isempty(varargin)
    p=struct();     
end %

%% INPUT CHECK AND DEFAULTS
%   Load defaults from SIN_defaults, then overwrite these by user specific
%   inputs. 
defs=SIN_defaults; 
d=defs.anl; 
FS=d.fs; 
% FS=22050; 

% OVERWRITE DEFAULTS
%   Overwrite defaults if user specifies something different.
flds=fieldnames(p);
for i=1:length(flds)
    d.(flds{i})=p.(flds{i}); 
end % i=1:length(flds)

% Clear p
%   Only want to use d for consistency and to minimize errors. So clear 'p'
%   to remove temptation.
clear p; 

%% LOAD DATA
%   Load X. Support WAV and double format, multi-channel OK
%   (infinite).
t.datatype=[1 2];
if isfield(d, 'fsx') && ~isempty(d.fsx), t.fs=d.fsx; end 
[X, fsx]=AA_loaddata(X, t); 

% Playback channel check
%   Confirm that the number of playback channels corresponds to the number
%   of columns of X and Y. 
if numel(d.playback_channels) ~= size(X,2)
    error('Incorrect number of playback channels specified'); 
end % if numel(p.playback_channels) ...

%% MATCH SAMPLING RATE
%   Resample playback sounds so they match the playback sampling rate.
X=resample(X, FS, fsx); 

%% LOAD PLAYBACK AND RECORDING DEVICES
%   Get these from SIN_defaults as well. 
InitializePsychSound; 

%% CREATE BUFFER
% Create empty playback buffer
buffer_nsamps=round(d.block_dur*FS)*2; % need 2 x the buffer duration

% Find buffer locations
buffer_ind=[1 buffer_nsamps/2+1];

%% OPEN PLAYbACK DEVICE
% Continuous playback
[pstruct]=portaudio_GetDevice(defs.playback.device);
phand = PsychPortAudio('Open', pstruct.DeviceIndex, 1, 0, FS, pstruct.NrOutputChannels); 

%% FILL X TO MATCH NUMBER OF CHANNELS
x=zeros(size(X,1), pstruct.NrOutputChannels);
x(:, d.playback_channels)=X; % copy data over into playback channels
X=x; % reassign X

% Clear temporary variable x 
clear x; 

%% CREATE WINDOWING FUNCTION (ramp on/off)
%   For ease, let's use a Hanning window for now (makes implementation more
%   straightforward). 
% win=window(@hann, round(0.005*2*FS)); % Create 5 ms onset/offset ramp
% win=ones(round(0.005*2*FS),1); % make a linear window (for now)
win=ones(buffer_nsamps/2, 1); 

% Match number of channels
win=win*ones(1, size(X,2)); 
% win=[win(1:length(win)/2, :); ones(buffer_nsamps/1-length(win), size(X,2)); win(length(win)/2:end, :)];
% 
% nblocks
nblocks=ceil(size(X,1)./size(win,1)); 

for i=1:nblocks
    
    % Which buffer block are we filling?
    %   Find start and end of the block
    startofblock=buffer_ind(1+mod(i-1,2));
    endofblock=startofblock+buffer_nsamps/2-1; 
    
    pstatus=PsychPortAudio('GetStatus', phand);    
      
    % Find data we want to load 
    if i==nblocks
        % Load with the remainder of X, then pad zeros. 
    else
        data=X(1+buffer_nsamps/2*(i-1):(buffer_nsamps/2)*i,:);
    end 
    
    % First time through, we need to start playback
    if i==1
        % Start audio playback, but do not advance until the device has really
        % started. Should help compensate for intialization time. 
        
        % Fill buffer with zeros
        PsychPortAudio('FillBuffer', phand, zeros(buffer_nsamps,size(data,2))'); 
        
        % Infinite repetitions
        PsychPortAudio('Start', phand, 0, [], 1);
        
    end % if i==1
    
    % Now, loop until we're half way through the samples in this particular
    % buffer block
    pstatus=PsychPortAudio('GetStatus', phand);
    
    % Load data into playback buffer
    PsychPortAudio('FillBuffer', phand, data', 1, startofblock);    
    
    % Wait for previous section to finish before rewriting the audio 
    while pstatus.ElapsedOutSamples < buffer_nsamps/2 * (i-1), pstatus=PsychPortAudio('GetStatus', phand); end
    
    pstatus=PsychPortAudio('GetStatus', phand);
    % Each time we're half way through a block, start rewriting the buffer
    while mod(pstatus.ElapsedOutSamples, buffer_nsamps) - startofblock < buffer_nsamps/4 
        pstatus=PsychPortAudio('GetStatus', phand); 
    end % while
    
end % while 1
    
%% SCAFFOLD SOUND PLAYBACK LOOP
%   Want to demonstrate that our sound playback loop will work in in
%   principle. 
%       Get a sound looping continuously by rewriting blocks of buffer.

% Get indices for data to write to block 1 and block 2
%   Block 1 fades out in block 2 (linear ramp, or whatever else we decide
%   to use)

%% ADAPTIVE LOOP
%   Loop to control adaptive sound playback.



