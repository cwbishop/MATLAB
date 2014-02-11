function results=gab_task_eeglab_swapfields(args)
%% DESCRIPTION:
%
%   This is a GAB friendly function designed to exchange (swap) a specific
%   field or set of fields between two EEG structures.  This can be done by
%   providing the function with paths to both files OR by providing a path
%   string to a mat file containing an EEG structure that has fields you
%   want to use to replace fields in the global EEG variable. The latter is
%   the default behavior.
%
% INPUT:
%   
%   args.
%       filename:   string, EEG matfile name
%       filepath:   path to EEG file
%       fields:     cell array of filed names
%       loadmode:   (optional; default 'all')
%
% OUTPUT:
%
%   results:    something gab likes but I don't since it doesn't do
%               anything useful.
%   
% Bishop, Christopher W.
%   UC Davis 
%   Miller Lab 2012
% cwbishop@ucdavis.edu

global EEG; 

if ~isfield(args, 'loadmode') || isempty(args.loadmode), args.loadmode='all'; end 

EEG1=pop_loadset('filename', args.filename, 'filepath', args.filepath, 'loadmode', args.loadmode);

for i=1:length(args.fields)
    EEG.(args.fields{i})=EEG1.(args.fields{i});
end % for i

results='done'; 