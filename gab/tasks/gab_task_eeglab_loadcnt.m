function results=gab_task_eeglab_loadcnt(args)
%% DESCRIPTION:
%
%   GAB call to EEGLAB's pop_loadcnt, which loads Neuroscan's CNT formatted
%   files. 
%   
% INPUT:
%
%   args:   structure with the following fields
%
%       .files:  cell array, each cell is the full path to a CNT file.
%       .loadandmerge:  boolean, merge data sets as they are loaded. This
%                       is useful when dealing with large datasets or
%                       computers with little memory. (default = false)
%       .dataformat:    data format ('int16' | 'int32' | 'auto'; default
%                       auto)
%       .memmapfile:    memory mapped file name. This must end with the
%                       extension .fdt for ... reasons. Thank you, EEGLAB.
%
% OUTPUT:
%
%   results:    hold over from GAB that never seems to be used.
%
% NOTE:
%   loadandmerge option didn't help me nearly as much as I thought it
%   would, probably because EEGLAB is ridiculous in the way it deals with
%   storing data (e.g., in ALLEEG and EEG separately ... thanks, EEGLAB).
%
% Bishop, Christopher
%   University of Washington
%   Oct 2013

global EEG;

%% DEFAULT INPUT VALUES
if ~isfield(args, 'dataformat') || isempty(args.dataformat), args.dataformat='auto'; end
if ~isfield(args, 'memmapfile') || isempty(args.memmapfile)
    
    % Load up empty cells by default
    for f=1:length(args.files)        
        args.memmapfile{f}=''; 
    end % for f=1:length(args.files)
    
end % if ~isfield(args, 'memmapfile') ...
if ~isfield(args, 'loadandmerge') || isempty(args.loadandmerge), args.loadandmerge=false; end

for f=1:length(args.files)
    
    % If LOADANDMERGE is set to true, then load up the first file, then the
    % second, merge, then load third file, merge 3rd with already merged
    % 1+2, etc. Repeat until all files are loaded.
    %
    % Otherwise, just load the data normally.
    if args.loadandmerge
        if f==1
            EEG(f)=pop_loadcnt(args.files{f}, 'dataformat', args.dataformat, 'memmapfile', args.memmapfile{f});
        else           
            EEG(2)=pop_loadcnt(args.files{f}, 'dataformat', args.dataformat, 'memmapfile', args.memmapfile{f});
            EEG = pop_mergeset(EEG,1:length(EEG));
        end % if f==1
    else
        EEG(f)=pop_loadcnt(args.files{f}, 'dataformat', args.dataformat, 'memmapfile', args.memmapfile{f});
    end % if args.loadandmerge
end % f=1:length(args.files)

results='done'; 