function results=gab_task_mergeset(args)
%% DESCRIPTION
%
%   Wrapper for merging datasets through gab.  Assumes data from all
%   merging datasets are loaded.
%
%   *NOTE*: pop_mergeset will convert all of your events to strings while
%           merging. If you have any other code that assumes that events
%           are anything but strings, then need to make all calls
%           compatible with strings.
%
% INPUTS
%
%   args
%       .indices:    data indices to merge (order matters)
%
% OUTPUTS
%
%   results 
%
% Bishop, Chris Miller Lab 2010

global EEG

EEG=pop_mergeset(EEG, args.indices);

results='done';