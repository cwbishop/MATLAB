function results=gab_task_eeglab_loadset(args)
%% DESCRIPTION
%
% INPUT:
%
%   args.filename
%   args.filepath
%   args.loadmode
%
% OUTPUT:
%
%   results:    'done'
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

global EEG;

%% DEFAULTS
if ~isfield(args, 'loadmode'), args.loadmode='all'; end
if ~isfield(args, 'filepath') || isempty(args.filepath), args.filepath=pwd; end

EEG=pop_loadset('filename', args.filename, 'filepath', args.filepath, 'loadmode', args.loadmode);

results='done';