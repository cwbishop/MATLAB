function result=gab_task_erplab_saveERP(args)
%% DESCRIPTION:
%
%   Wrapper for ERPLAB's saveERP (business end of pop_savemyerp).  Saves
%   the currently selected ERP set to disk.
%
% INPUT:
%
%   args.
%       filenamex:  path (full or relative) where ERP should be saved.
%       modegui:    gui mode (1=use GUI, 0=no GUI)
%       
% OUTPUT:
%
%   results:        'done';
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

global ERP

%% DEFAULTS
% Since GAB is meant for batching, default is to not use GUI
if ~isfield(args, 'modegui') || isempty(args.modegui), args.modegui=0; end

saveERP(args.filenamex, args.modegui);

results='done';