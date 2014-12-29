function results = gab_task_erplab_pop_binoperator(args)
%% DESCRIPTION:
%
%   Wrapper function to execute bin operations using ERPLAB's
%   pop_binoperator function.
%
% INPUT:
%
%   args
%
%   'formulas': this can take several formats, but the easiest is a path to
%               a file containing the bin operations.
%
% OUTPUT:
%
%   results:    
%
% Christopher W Bishop
%   University of Washington
%   12/14

cmd = ['ERP = pop_binoperator(ERP, ''' args.formulas ''');'];

evalin('base', cmd); 

results = 'done';