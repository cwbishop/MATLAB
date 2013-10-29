function results=gab_task_eeglab_reref(args)
%% DESCRIPTION
%
%   Wrapper function for EEGLAB's pop_reref used to rereference data.
%   
%   Please Note: CB discovered a small, but significant bug in EEGLAB's
%   reref.m at line 309.  The issue only arises when users attempt to apply
%   a reference to a subset of channels. E-mail him for a fix if you don't
%   have it.
%
% INPUT:
%   
%   args.
%       ref
%       exclude
%       keepref
%       refloc
%
% OUTPUT:
%
%   results:    'done'
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

%% LOAD GLOBALS
global EEG ALLEEG;

%% DEFAULTS
if ~isfield(args, 'exclude'), args.exclude=[]; end

%% REREFERENCE
%   Assumes you are editing the currently selected EEG dataset.
EEG=pop_reref(EEG, args.ref, 'exclude', args.exclude); 

%% GAB RESULTS
results='done';