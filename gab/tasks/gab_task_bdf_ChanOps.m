function [results HDR HEADER HEADEROUT, DATA]=gab_task_bdf_ChanOps(args)
%% DESCRIPTION:
%
%   GAB wrapper for bdf_ChanOps. NOTE: That 'Status' channel is NOT
%   included in the output BDF by default. This must be explicitly defined.
%
% INPUT:
%
%   args.
%       IN:         string, full path to original BDF
%       OUT:        string, full path to output file
%       CHANOPS:    cell array, where each cell specifies the mathematical
%                   expression for an output channel (e.g. {'(A1+A2)./2'}
%                   to average over channels A1 and A2). 
%       OCHLAB:     cell array, each element is the name that will be
%                   assigned to the output channel (e.g. {'Vertex',
%                   'Reference'});
% OUTPUT:
%
%   results:    useless thing for GAB.
% 
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2012
%   cwbishop@ucdavis.edu

% bdf_ChanOps call
[HDR, HEADER, HEADEROUT, DATA]=bdf_ChanOps(args.IN, args.OUT, args.CHANOPS, args.OCHLAB);

results='done';