function [results]=gab_task_erplab_basicfilter(args)
%% DESCRIPTION:
%
% INPUT:
%
%   These inputs are taken directly from pop_basicfilter.m.  Please refer
%   to pop_basicfilter.m for a complete description of these variables.  A
%   brief description of each is provided here.
%
%   args.channels:      channels to filter (e.g. 1:64; default=EEG.nbchan)
%   args.locutoff:      lower corner frequency
%   args.hicutoff:      high corner frequency
%   args.filterorder:   filter order (e.g. 2)
%   args.typef:         filter type (e.g. 'butter' or 'fir')
%   args.remove_dc:     remove DC offset (1=yes, 0=no; defualt=1)
%   args.boundary:      boundary event (default='boundary')
%
% OUTPUT:
%
%   results:
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

%% LOAD EEG STRUCT
global EEG;

%% DEFAULTS
% Remove DC offset (1=yes, 0=no)
if ~isfield(args, 'remove_dc'), args.remove_dc=1; end
% Channels to filter
if ~isfield(args, 'channels') || isempty(args.channels), args.channels=1:EEG.nbchan; end
% Boundary event code
if ~isfield(args, 'boundary') || isempty(args.boundary), args.boundary='boundary'; end

EEG=pop_basicfilter( EEG, args.channels, args.locutoff, args.hicutoff, args.filterorder, args.typef, args.remove_dc, args.boundary );

results='done';