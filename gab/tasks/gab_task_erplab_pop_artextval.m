function results = gab_task_erplab_pop_artextval(args)
% The available parameters are as follows:
%
%        'Twindow' 	- time period (in ms) to apply this tool (start end). Example [-200 800]
%        'Threshold'    - range of amplitude (in uV). e.g  -100 100
%        'Channel' 	- channel(s) to search artifacts.
%        'Flag'         - flag value between 1 to 8 to be marked when an artifact is found.(1 value)
%        'Review'       - open a popup window for scrolling marked epochs.
%
% Christopher W. Bishop
%   University of Washington
%   12/13

global EEG;

EEG = pop_artextval(EEG, args.params{:});

results='done';