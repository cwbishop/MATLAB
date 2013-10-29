function results=gab_task_erplab_creabasiceventlist(args)
%% DESCRIPTION:
%
%   Wrapper function to create a basic event list using ERPLAB's
%   pop_creabasiceventlist.m
%
% INPUT:
%
%   args.
%       elname: eventlist name (text file to save event list to)
%       boundarystrcode:
%       newboundarynumcode: 
%
% OUTPUT:
%
%   results:    
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

%% LOAD GLOBAL VARIABLES
global EEG; 

%% DEFAULTS
if ~isfield(args, 'elname'), args.elname=''; end
if ~isfield(args, 'boundarystrcode'), args.boundarystrcode={'boundary'}; end
if ~isfield(args, 'newboundarynumcode'), args.newboundarynumcode={-99}; end

%% CREATE EVENT LIST
EEG = pop_creabasiceventlist(EEG, args.elname, args.boundarystrcode, args.newboundarynumcode);

%% GAB STUFF
results='done'; 