function results=gab_task_eeglab_saveset(args)
%% DESCRIPTION:
%
%   Save EEG data set.  Calls pop_saveset.m.  See pop_saveset for full
%   description.
%
% INPUT:
%
%   args.filename:  Name of file
%   args.filepath:  file path
%   args.check:     run syntax check
%   args.savemode:  see eeg_options for details. Edit with
%                   pop_editoptions.m
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
% Set savemode and check to [] so eeg_options default is used.
if ~isfield(args, 'savemode'), args.savemode=''; end
if ~isfield(args, 'check'), args.check='off'; end
% filepath set to current working directory if not specified.
if ~isfield(args, 'filepath'), args.filepath=pwd; end

EEG=pop_saveset(EEG, 'filename', args.filename, 'filepath', args.filepath, 'check', args.check, 'savemode', args.savemode);

results='done';