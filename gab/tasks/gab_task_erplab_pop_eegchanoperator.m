function results=gab_task_erplab_pop_eegchanoperator(args)
%% DESCRIPTION:
%
%   Wrapper function for pop_eegchanoperator.
%
% INPUT:
%
%   args
%     .formulas:    cell array of formulas. like {  'ch65=ch13-ch13 label Cz'}
%
% OUTPUT:
%
%   results:    
%
% Christopher W. Bishop
%   University of Washington
%   7/15

% Get the EEG dataset
global EEG

EEG = pop_eegchanoperator( EEG, args.formulas , 'ErrorMsg', 'popup', 'Warning', 'off' );

results = 'done'; 