function results=gab_task_erplab_loaderp(args)
%% DESCRIPTION
%
%   Wrapper to load ERP data into ERP Lab.  This currently only works with
%   multiple files with a slightly hacked version of pop_loaderp.  I will
%   have to e-mail the developers and address the issue with them directly.
%
%   Specifically
%
%       if ~errorf && ~serror && nargin==1
%
%   is replaced with
%
%       if ~errorf && ~serror && (nargin==1 || isempty(pathname)) %% Modified by CWB
%
% INPUT:
%
%   args.
%       filename:   cell array, each cell is a full path to the file
%                   containing the saved ERPset
%
% OUTPUT:
%
%   results:    'done'
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

pop_loaderp(args.filename, '');

results='done';