function results=gab_task_erplab_pop_averager(args)
%% DESCRIPTION:
%
%   
%
% INPUT:
%
%   args.
%       params
%           'DSindex' 	- dataset index(ices) when dataset(s) are contained within the ALLEEG structure.
%                         For single bin-epoched dataset using EEG structure this value must be equal to 1 or
%                         left unspecified.
%           'Criterion'    - Inclusion/exclusion of marked epochs during artifact detection:
%               'all'   - include all epochs (ignore artifact detections)
% 		        'good'  - exclude epochs marked during artifact detection
% 		        'bad'   - include only epochs marked with artifact rejection
%               NOTE: for including epochs selected by the user, specify these one as a cell array. e.g {2 8 14 21 40:89}
%
%           'SEM'              - include standard error of the mean. 'on'/'off'
%           'ExcludeBoundary'  - exclude epochs having boundary events. 'on'/'off'
%           'Saveas'           - (optional) open GUI for saving averaged ERPset. 'on'/'off'
%           'Warning'          - enable popup window warning. 'on'/'off'
%
% OUTPUT
%
%   results
%
% Bishop, Christopher
%   University of Washington
%   11/13

global EEG ERP;

ERP = pop_averager(EEG, args.params{:});

results='done';