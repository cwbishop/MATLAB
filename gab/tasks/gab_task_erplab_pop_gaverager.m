function results=gab_task_erplab_pop_gaverager(args)
%% DESCRIPTION:
%
%   Simple wrapper for ERPLAB grand averager. This will operate on the 
%   ALLERP structure loaded in the base workspace. 
%
% INPUT:
%
%   args.
%
%       params: parameter list
%
%           'Erpsets'         - index(es) pointing to ERP structures within ALLERP (only valid when ALLERP is specified)
%           'Weighted'        - 'on' means apply weighted-average, 'off' means classic average.
%           'SEM'             - Get standard error of the mean. 'on' or 'off'
%           'ExcludeNullBin'  - Exclude any null bin from non-weighted averaging (Bin that has zero "epochs" when averaged)
%           'Warning'         - Warning 'on' or 'off'
%           'Criterion'       - Max allowed mean artifact detection proportion
%       
% OUTPUT:
%
%   results:    'done'
%
% Christopher W. Bishop
%   University of Washington 
%   12/13

% Generate the command
cmd = ['ERP = pop_gaverager(ERP' gab_params2str(args.params) ');'];

% Evaluate the command in the base workspace 
evalin('base', cmd); 

results='done'; 