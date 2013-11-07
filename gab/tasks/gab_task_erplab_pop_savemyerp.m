function results = gab_task_erplab_pop_savemyerp(args)
%% DESCRIPTION:
%
%   
%
% INPUT:
%
%   args.
%       params
%         'erpname'          - ERP name to be saved
%         'filename'         - name of ERP to be saved
%         'filepath'         - name of path ERP is to be saved in
%         'gui'              - 'save', 'saveas', 'erplab' or 'none'
%         'overwriteatmenu'  - overwite erpset at erpsetmenu (no gui). 'on'/'off'
%         'Warning'          - 'on'/'off'
%
% OUTPUT
%
%   results
%
% Bishop, Christopher
%   University of Washington
%   11/13

global ERP;

pop_savemyerp(ERP, args.params{:}); 

results = 'done';