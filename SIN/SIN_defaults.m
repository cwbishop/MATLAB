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
defaults.playback.device=portaudio_GetDevice(8); 

% Default recording device
defaults.record.device=portaudio_GetDevice(6); 

%% HAGERMAN RECORDING DEFAULTS
%   Defaults for Hagerman_record (used for standard Hagerman style, phase
%   inverted recordings). 
defaults.hagerman.fs=defaults.fs;
defaults.hagerman.playback_channels=2;  % play to right channel only
defaults.hagerman.sigtag_type='10Hzclicktrain'; % see Hagerman_record for other options.
defaults.hagerman.sigtag_loc='pre'; 
% Mixing matrix simplified for testing purposes. Only extract one signal
% (X) 
defaults.hagerman.mixing_matrix=[... % presets adjusted for testing with Alice
    [0.5 0.1] % native polarity for X and Y
    [0.5 -0.1] ];% X native, Y inverted
%     [-0.5 0.1] % X inverted, Y native
%     [-0.5 -0.1]]; % both signals inverted
defaults.hagerman.pflag=0; % don't plot anything by default.
defaults.hagerman.xtag='Sp'; % tag for target speech
defaults.hagerman.ytag='No'; % tag for noise (babbly or speech shaped noise) 
defaults.hagerman.filename_root=''; % don't provide a filename root by default, force user to enter this. 
defaults.hagerman.write_nbits=32; % bit depth for written wav files from hagerman_record
defaults.hagerman.write=true; % write wav files by default 

%% Acceptable Noise Level (ANL) defaults
% Set sampling rate to the default study sampling rate
defaults.anl.fs=defaults.fs;

% Set adaptive mode for adaptive sound playback to 'realtime', which allows
% for (near) real-time changes to the auditory stream. 
defaults.anl.adaptive_mode='realtime'; 

% Set playback inform
defaults.anl.playback_channels=[1 2]; % just play sounds from one speaker
defaults.anl.block_dur=.08; % block duration in sec. 0.08 leads to a buffer of 0.16 s (160 ms). 
                            % Generally, the maxmimum delay of signal
                            % modification (see portaudio_adaptiveplay for
                            % details).       
                            
% List modification checks and modifiers for portaudio_adaptiveplay
defaults.anl.modcheck.fhandle=@ANL_modcheck_keypress; 
defaults.anl.modifier.fhandle=@ANL_modifier_dBscale; 

% Fields for modifier
defaults.anl.modifier.dBstep=1; 

% Create button mapping for button feedback
%   These values are used by ANL_modcheck_keypress.m. See function for
%   details of use and values. The short version is that we monitor for
%   presses of the up and down arrow keys. 
%
%   Different mod_code sent for each button pressed.
defaults.anl.modcheck.keys=[KbName('up') KbName('down')];

% Create a map for keyboard key creation 
defaults.anl.modcheck.map=zeros(256,1); defaults.anl.modcheck.map(defaults.anl.modcheck.keys)=1; 

%% HINT DEFAULTS
%   Default values for the HINT. 

% General %
% Root directory of HINT stimuli 
defaults.hint.root='C:\Users\cwbishop\Documents\GitHub\MATLAB\SIN\playback\HINT';
defaults.hint.playback_channels=[1 2]; % play sound to channels 1 and 2. 
defaults.hint.fs=defaults.fs; % inherit default sampling rate. 
defaults.hint.playback=defaults.playback; % grab the default playback device. 

% portaudio_adaptiveplay %
% Adaptive algorithm 
%   Gather feedback after each file is presented
defaults.hint.adaptive_mode='byfile'; % gather feedback after each sentence. 
defaults.hint.block_dur=0.08; % 80 ms buffer; only used if 'realtime' playback selected.
defaults.hint.append_files=false; % keep the files separate
defaults.hint.stop_if_errors=true; % abort test if errors are encountered.

% HINT List loading paramters
%   filename:   path to HINT xlsx file containing HINT stimuli information.
%   sheetnum:   sheet number to load from the xlsx file (#2 has the most
%               sensicle entries; add sheets if you want something
%               different)
defaults.hint.list.filename=fullfile(defaults.hint.root, 'HINT.xlsx');
defaults.hint.list.sheetnum=2;

% modcheck configuration
%   We use a GUI for scoring. For details on additional parameters, see
%   HINT_modcheck_GUI
defaults.hint.modcheck.fhandle=@HINT_modcheck_GUI;
defaults.hint.modcheck.target=0.50; % proportion of correct responses to target
defaults.hint.modcheck.scoring_method='sentence_based'; 
defaults.hint.modcheck.scoring_labels={'Correct' 'Incorrect'}; 

% modifier_dBscale %
%   Parameters needed for modifer_dBscale. If a different modifier is used,
%   replace these fields with whatever the modifier requires (see the
%   modifier help). 
defaults.hint.modifier.fhandle=@modifier_dBscale; 
defaults.hint.modifier.dBstep=2; % 2 dB steps to begin with. This is totally arbitrary
defaults.hint.modifier.change_step=1; % the trial on which to start applying the dBstep
defaults.hint.modifier.channels=defaults.hint.playback_channels;