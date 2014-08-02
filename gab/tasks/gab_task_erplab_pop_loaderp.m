function results = gab_task_erplab_pop_loaderp(args)
%% DESCRIPTION:
%
%   Wrapper for ERPLAB's pop_loaderp function
%
% INPUT:
%
%   args:
%
%   ERPF:   cell array of filenames
%
%       params: (NOTE THAT PARAMS DO NOT WORK AT THIS TIME)
%
%           'filepath'        - ERPset's filepath
%           'overwrite'       - overwrite current erpset. 'on'/'off'
%           'Warning'         - 'on'/'off'
%           'multiload'       - load multiple ERPset using a single output variable (see example 2). 'on'/'off'
%           'UpdateMainGui'   - 'on'/'off'
%
% OUTPUT:
%
%   results: hold over from GAB design
%
%   ERP: ERP structure loaded into base workspace.
%
% Christopher W. Bishop
%   University of Washington
%   8/14

for i=1:length(args.ERPF)
    [PATHSTR,NAME,EXT] = fileparts(args.ERPF{i});
    ERP(i) = pop_loaderp('filepath', PATHSTR, 'filename', [NAME EXT]); 
end % for i=1:length(ERPF)

% Assign in base workspace
assignin('base', 'ERP', ERP); 

results = 'done';
