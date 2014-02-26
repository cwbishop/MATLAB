function results=gab_task_CNT_CHANOPS(args)
%% DESCRIPTION:
%
%   GAB wrapper for CNT_CHANOPS
%
% INPUT:
%
%   args. 
%       IN: cell array, input file names
%       OUT:    cell array, output file names
%       CHANOPS:    cell array, channel operations
%       OCHLAB: cell array, output channel labels
%       BLOCKSIZE:  double, data block size during reading. (sec).
%                   Recommend 1 sec. If memory errors persist, reduce block
%                   size setting.
%       DATAFORMAT: 'int16' | 'int32'; If empty, the native precision of 
%                   the input file is used. Recommend leaving this empty.
%       PRECISION:  'single' | 'double'. 
%
% OUTPUT:
%
%    CNT files (OUT). 
%
% Christopher W. Bishop
%   University of Washington
%   2/14   

%% INPUT CHECKS

% Are there a sufficient number of output files to match the number of
% input files?
if length(args.IN) ~= length(args.OUT)
    error('Incorrect number of output files');
end % if length

%% LOOP THROUGH ALL FILES
%   Since we accept a cell array, do the following on 
for i=1:length(args.IN)
    CNT_CHANOPS(args.IN{i}, args.OUT{i}, args.CHANOPS, args.OCHLAB, args.BLOCKSIZE, args.DATAFORMAT, args.PRECISION)
end % i=1:length(args.IN)

%% SET RESULTS
results='done';