function results=gab_task_erplab_gaverager(args)
%% DESCRIPTION
%
%   GAB wrapper for ERPLAB's pop_gaverager for computing grand averaged
%   ERPs.
%
% INPUT:   
%
%   args.
%       erp_index:  index of ERPs to average (default is all ERPs loaded)
%       iswavg:     is weight averaged (1=weighted 0=classic average)
%
% OUTPUT:
%   
%   results:    'done'
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

% global ALLERP; uh apparently ALLERP isn't a global variable.

%% DEFAULTS
%   This default is broken because ALLERP isn't a global variable like
%   ALLEEG
if ~isfield(args, 'erp_index') || isempty(args.erp_index), args.erp_index=1:length(ALLERP); end

%% FUNCTION CALL
cmd=['pop_gaverager(ALLERP,[' num2str(args.erp_index) '],' num2str(args.iswavg) ');'];
evalin('base', cmd);
evalin('base', 'updatemenuerp(ALLERP)');


%% GAB BUSINESS?
results='done';