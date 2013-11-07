function results = gab_task_erplab_pop_epochbin(args)
%% DESCRIPTION:
%
%   
%
% INPUT:
%
%   args.
%       trange    - window for epoching in msec
%       blc       - window for baseline correction in msec or either a string like 'pre', 'post', or 'all'
%            (strings with the baseline interval also works. e.g. '-300 100')
%
% OUTPUT
%
%   results
%
% Bishop, Christopher
%   University of Washington
%   11/13

global EEG;

for i=1:length(EEG)
    EEG(i)=pop_epochbin(EEG(i), args.trange, args.blc); 
end % i
results='done'; 