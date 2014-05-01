function defaults=SIN_defaults
%% DESCRIPTION:
%
%   Function to set and retrun defaults for speech in noise (SIN) testing
%   suite. 
%
% INPUT:
%
%   None (yet). 
%
% OUTPUT:
%
%   defaults:   structure with lots of default values
%                   The details of this are evolving too much to include a
%                   description at present.
%
% Christopher W. Bishop
%   University of Washington 
%   5/14

%% GLOBAL DEFAULTS
%   Set some global defaults that are inherited below. This should include
%   information like sampling rate, etc. provided it should be held
%   constant across all functions

% Default sampling rate
defaults.fs=44100; 

% Default playback device
%   Use portaudio_GetDevice to get the proper playback device information.
%       Hardcoded to what CWB needs to test his PC for the time being. 
%       Keep in mind, however, that this information is subject to change
%       if devices are added or removed. That would be bad and lead to
%       weird erros. CWB still hasn't found a consistent way to grab the
%       same device every time. 
defaults.playback.device=portaudio_GetDevice(4); 

% Default recording device
defaults.record.device=portaudio_GetDevice(2); 

%% HINT

% Root directory of HINT stimuli 
defaults.hint.root='C:\Users\cwbishop\Documents\GitHub\MATLAB\SIN\playback\HINT';

%% HAGERMAN RECORDING DEFAULTS
%   Default values for Hagerman style recordings for SNR estimation 
defaults.hagerman.fs=defaults.fs;
defaults.hagerman.playback_channels=[1 2]; 
defaults.hagerman.sigtag_type='10Hzclicktrain'; % see Hagerman_record for other options.
defaults.hagerman.sigtag_loc='pre'; 
defaults.hagerman.mixing_matrix=[...
    [0.5 0.5] % native polarity for X and Y
    [0.5 -0.5] % X native, Y inverted
    [-0.5 0.5] % X inverted, Y native
    [-0.5 -0.5]]; % both signals inverted
defaults.hagerman.pflag=0; % don't plot anything by default.