function results=gab_task_eeglab_newtimef(args)
%% DESCRIPTION:
%
%   Function call for EEGLAB's newtimef. Call based on MSPE_spect.m.
%
% INPUT:
%
%   args.
%       OFILE:  string, full path to output mat file. Results are saved in
%               this mat file.
%       
% OUTPUT:
%
%   results:    'done'. 
% Christopher W. Bishop
%   University of Washington
%   12/13

global EEG; 

results = 'done';