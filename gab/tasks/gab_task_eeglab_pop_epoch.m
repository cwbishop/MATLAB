function results = gab_task_eeglab_pop_epoch(args)
%% DESCRIPTION:
%
%   GAB wrapper for EEGLAB's pop_epoch function
%
% INPUT:
%
%   args.
%       events: string, events to epoch. ([]=all, '10 11 12' just epoches 10, 11, 12, etc.
%       lim:    time window (s); e.g. [-0.11 1.1]
%       params: cell array, optional inputs.
%           Optional inputs:
%               'eventindices'- [integer vector] Extract data epochs time locked to the 
%                                indexed event numbers. 
%               'valuelim' -    [min max] or [max]. Lower and upper bound latencies for 
%                               trial data. Else if one positive value is given, use its 
%                               negative as the lower bound. The given values are also 
%                               considered outliers (min max) {default: none}
%               'verbose'  - ['yes'|'no'] {default: 'yes'}
%               'newname'  - [string] New dataset name {default: "[old_dataset] epochs"}
%               'epochinfo'- ['yes'|'no'] Propagate event information into the new
%                           epoch structure {default: 'yes'}
%
% OUTPUT:
%
%   results:    you know the story
%
% Christopher W. Bishop
%   University of Washington
%   11/2013

global EEG; 

% Epoch all EEG datasets in EEG structure
for i=1:length(EEG)
    EEG(i)=pop_epoch(EEG(i), args.events, args.lim, args.params{:});
end % for i=1:length(EEG)

results = 'done';