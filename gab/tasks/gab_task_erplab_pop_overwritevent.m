function results=gab_task_erplab_pop_overwritevent(args)
%% DESCRIPTION:
%
%   
%
% INPUT:
%
%   args.
%       mainfield:  name of field from EEG.EVENTLIST.eventinfo to be copied into EEG.event.type. 'code','codelabel', or 'binlabel'.
%
% OUTPUT
%
%   results
%
% Bishop, Christopher
%   University of Washington
%   11/13

global EEG;

for i=1:length(EEG)
    EEG(i)=pop_overwritevent(EEG(i), args.mainfield); 
end % i=1:length(EEG)

results='done';