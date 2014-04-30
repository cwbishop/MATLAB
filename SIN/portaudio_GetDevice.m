function [D]=portaudio_GetDevice(X, varargin)
%% DESCRIPTION:
%
%   Function to find and return device based on input information. Input
%   information can currently only be a string. 
%
%   String matching is not always successful since often times a single
%   physical device will have multiple methods interfaces (e.g., ASIO, MME,
%   etc.). For more information, see 
%
%           http://docs.psychtoolbox.org/GetDevices
%
% INPUT:
%
%   X:  string, name of device.
%
% Parameters:
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
%   Y:  integer, device index for use with PsychPortAudio
%   d:  structure, device structure.
%
% Christopher W. Bishop
%   University of Washington
%   4/14

%% DEAL WITH ADDITIONAL PARAMETERS
if length(varargin)>1
    p=struct(varargin{:}); 
elseif length(varargin)==1
    p=varargin{1};
elseif isempty(varargin)
    p=struct();     
end %

%% DEFAULT PARAMTERS
if ~isfield(p, 'devicetype'), p.devicetype=[]; end;

%% INITIALIZE PSYCHSOUND
InitializePsychSound;

% Get devices
d=PsychPortAudio('GetDevices', p.devicetype);

% If an index is provided, then just spit back the device structure and
% device index. 
if isempty(X) || isa(X, 'numeric') 
    Y=X; 
    D=PsychPortAudio('GetDevices', [], X); 
    return
end % if isempty(X) ...

% If X is not a string, kick it back
if ~isa(X, 'char') 
    error(['I cannot deal with a ' class(X)] ); 
end % if ~isa(X, 'char'); 

%% FIND DEVICE
% Gather names
dnames={d(:).DeviceName};

% String match
Y=strmatch(X, dnames, 'exact'); 
D=d(Y);

%% ERROR CHECKING
%   Throw an error if we find multiple hits
if numel(Y) > 1
    error('Multiple devices found. Try specifying the devicetype parameter.');
elseif numel(Y)==0
    error('Device not found');
end % numel(Y)

%% GET DEVICE ID
Y=d(Y).DeviceIndex;