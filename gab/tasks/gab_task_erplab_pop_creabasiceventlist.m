function results=gab_task_erplab_pop_creabasiceventlist(args)
%% DESCRIPTION
%
%
% INPUT:
%
%   args.params:    cell array of parameter inputs for
%                   pop_creabasiceventlist. Parameters described below.
%   
%    'Eventlist'             - name (and path) of eventlist text file to export.
%    'BoundaryString'        - boundary string code to be converted into a numeric code.
%    'BoundaryNumeric'           - numeric code that boundary string code is to be converted to
%    'BoundaryString'        - Name of string code that is to be converted
%    'BoundaryNumeric'       - Numeric code that string code is to be converted to
%    'Warning'               - 'on'- Warn if eventlist will be overwritten. 'off'- Don't warn if eventlist will be overwritten.
%    'AlphanumericCleaning'  - Delete alphabetic character(s) from alphanumeric event codes (if any). 'on'/'off'
%
% OUTPUT:
%
%   results:    'done'
%
% Bishop, Christopher
%   University of Washington
%   11/2013

global EEG;

EEG = pop_creabasiceventlist(EEG, args.params{:});

results='done'; 