function CNT_CHANOPS(IN, OUT, CHANOPS, OCHLAB)
%% DESCRIPTION:
%
%   Function to perform channel operations (e.g., referencing) of Neuroscan
%   CNT files. This has been useful when dealing with large (>5 GB) CNT
%   files that cannot always be loaded into a standard desktop computer.
%   EEGLAB v12.0.2.5b has memory mapping functionality with CNT files that
%   dramatically reduce the memory requirements, but it slows computation
%   time (particularly epoching functions) to a crawl. With a single
%   channel of data sampled at 20 kHz that can be epoched in ~3-5 mins
%   without memory mapping, it takes 30 - 90 minutes with memory mapping
%   enabled. Thus it became necessary to potentially rewrite data with only
%   select channels or to perform referencing in a multiplexed CNT format.
%
%   This requires a modified version of EEGLAB's 'loadcnt' as well as
%   'writecnt'. Please see their respective help files. 
%
% INPUT:
%
%   IN:  string, path to original BDF.
%   OUT: string, path to trimmed BDF.
%   CHANOPS:    cell array, each element contains a mathematical evaluation
%               string (e.g. '(A1 + A2)./2' to average channels A1 and A2).
%               Note that channel names in CHANOPS must match the channel
%               names in the BDF precisely.
%
%               *Note*: Function assumes all channels included in a given
%               operation -- that is, an element of the cell array -- are
%               of the same transducer type and sampling rate. A safe 
%               assumption for EEG, but could be a problem for other
%               applications.
%   OCHLAB: cell array, output channel names. Must be the same length as
%           CHANOPS. (optional input)
%
% OUTPUT:
%
%   nothing useful that I can think of ...
%
% Christopher W. Bishop
%   1/14
%   University of Washington