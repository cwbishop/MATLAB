function results=gab_task_erplab_pop_binlister(args)
%% DESCRIPTION:
%
%   
%
% INPUT:
%
%
%
% OUTPUT:
%
%
%
% Bishop, Christopher
%   University of Washington
%   11/2013

global EEG;

% ERPLAB runs binlister on each dataset independently, not sure why. But
% fine, we'll just loop the call here.
for i=1:length(EEG)
    EEG(i) = pop_binlister(EEG(i), args.params{:}); 
end % i

% GAB OUTPUT
results='done';