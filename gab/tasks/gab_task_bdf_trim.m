function [results]=gab_task_bdf_trim(args)
%% DESCRIPTION:
%
%   Wrapper function for GAB to extract specific channels from a BIOSEMI
%   BDF and write only the extracted channels to a separate file. This
%   proved to be necessary when recording auditory brainstem responses
%   (ABRs) since the sampling rate is often quite high (16.384 kHz in our
%   case) and few machines can load more than a channel or two at a time.  
%
%   For further details on use, see bdf_trim.m.  An important note is that
%   bdf_trim does *not* automatically include the 'Status' channel. This
%   contains event code information so you'll want to be sure to include it
%   in most cases.
%
% INPUT:
%
%   args
%       args.IN:    string, path to input BDF
%       args.OUT:   string, path to output (trimmed) BDF
%       args.CHANNELS:  character array of CHANNELS to extract (e.g.
%       strvcat('A1', 'Status'))
%
% OUTPUT:
%
%   results:    something to make GAB happy that I don't think is used for
%               anything
%   Trimmed BDF at args.OUT
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

bdf_trim(args.IN, args.OUT, args.CHANNELS); 

results='done'; 