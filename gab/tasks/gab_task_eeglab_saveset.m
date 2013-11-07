function results=gab_task_eeglab_saveset(args)
%% DESCRIPTION:
%
%   Save EEG data set.  Calls pop_saveset.m.  See pop_saveset for full
%   description.
%
% INPUT:
%
%   args.
%       params
%           'filename' - [string] name of the file to save to
%           'filepath' - [string] path of the file to save to
%           'check'    - ['on'|'off'] perform extended syntax check. Default 'off'.
%           'savemode' - ['resave'|'onefile'|'twofiles'] 'resave' resave the 
%                current dataset using the filename and path stored
%                in the dataset; 'onefile' saves the full EEG 
%                structure in a Matlab '.set' file, 'twofiles' saves 
%                the structure without the data in a Matlab '.set' file
%                and the transposed data in a binary float '.dat' file.
%                By default the option from the eeg_options.m file is 
%                used.
%           'version' - ['6'|'7.3'] save Matlab file as version 6 (default) or
%                   '7.3' (large files).
%
% OUTPUT:
%
%   results:    'done';
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

global EEG;

%% DEFAULTS
EEG=pop_saveset(EEG, args.params{:});

results='done';