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

% This now requires the filename and filepath fields to be cell arrays.
% Force this to be true if a single string is passed in. 
if ~iscell(args.filepath), args.filepath = {args.filepath}; end
if ~iscell(args.filename), args.filename = {args.filename}; end 

% Support loading multiple files
for i=1:numel(args.filepath)
    if i == 1
        EEG = pop_loadset('filename', args.filename{i}, 'filepath', args.filepath{i}, 'loadmode', args.loadmode);
    else
        EEG(i) = pop_loadset('filename', args.filename{i}, 'filepath', args.filepath{i}, 'loadmode', args.loadmode);
    end % 
end % for i=1:numel(filepath)

results='done';