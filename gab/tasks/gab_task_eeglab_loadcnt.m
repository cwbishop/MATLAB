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
%       .memmapfile:    memory map file (default=''). Not entirely sure
%                       what this does for CNT files at present. See
%                       loadcnt() for more details.
%
% OUTPUT:
%
%   results:    hold over from GAB that never seems to be used.
%
% Bishop, Christopher
%   University of Washington
%   Oct 2013

global EEG;

%% DEFAULT INPUT VALUES
if ~isfield(args, 'dataformat') || isempty(args.dataformat), args.dataformat='auto'; end
if ~isfield(args, 'memmapfile') || isempty(args.memmapfile), args.memmapfile=''; end
if ~isfield(args, 'loadandmerge') || isempty(args.loadandmerge), args.loadandmerge=false; end

for f=1:length(args.files)
    if args.loadandmerge
        if f==1
            EEG(f)=pop_loadcnt(args.files{f}, 'dataformat', args.dataformat, 'memmapfile', args.memmapfile);
        else           
            EEG(2)=pop_loadcnt(args.files{f}, 'dataformat', args.dataformat, 'memmapfile', args.memmapfile);
            EEG = pop_mergeset(EEG,1:length(EEG));
        end % if f==1
    else
        EEG(f)=pop_loadcnt(args.files{f}, 'dataformat', args.dataformat, 'memmapfile', args.memmapfile);
    end % if args.loadandmerge
end % f=1:length(args.files)

results='done'; 