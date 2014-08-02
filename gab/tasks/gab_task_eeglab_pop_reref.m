function results = gab_task_eeglab_pop_reref(args)
%% DESCRIPTION:
%
%   Wrapper function for EEGLAB's pop_reref function used to rereference
%   EEG data sets.
%
% INPUT:
%
%   args.
%       ref:    integer array of electrode numbers to use in reference.
%       params: optional parameters.
%           'exclude'   - [integer array] List of channels to exclude. 
%           'keepref'   - ['on'|'off'] keep the reference channel. 
%           'refloc'    - [structure] Previous reference channel structure.
%
% OUTPUT:
%
%   results:    useless variable for GAB
%
% Christopher W. Bishop
%   University of Washington
%   8/14

global EEG; 

EEG = pop_reref(EEG, args.ref, args.params{:});

results='done';