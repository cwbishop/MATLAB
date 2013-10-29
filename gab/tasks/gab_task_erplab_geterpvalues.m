function results=gab_task_erplab_geterpvalues(args)
%% DESCRIPTION
%
%   Wrapper for pop_geterpvalues (function called with ERP Measurement in
%   GUI).  This is quite possibly the ugliest thing I've written in the
%   last 12 months. Don't judge me.
%
% INPUT:
%
%   args.
%       latency:    time(s) of measurement. 
%       binArray:   bins to apply operations to.
%       chanArray:  channels to apply operations to.
%       options:    see pop_geterpvalues for details.
%
% OUTPUT:
%
%   results:    something GAB needs but apparently has no real function.
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

global ALLERP;

%% DEFAULTS

%% BUILD FUNCTION CALL
str='pop_geterpvalues(ALLERP,';

% Add latency information
if length(args.latency)==1
    str=[str num2str(args.latency) ','];
else
    str=[str '[' num2str(args.latency(1)) ' ' num2str(args.latency(2)) '],'];
end % if length(args.latency)

% Add in binArray
str=[str '[' num2str(args.binArray) '],'];

% Add in chanArray
str=[str '[' num2str(args.chanArray) '],'];

% Add in options
for i=1:size(args.options,1)
    if i~=size(args.options,1)
        str=[str args.options{i,1} ','];
        str=[str num2str(args.options{i,2}) ','];
    else
        str=[str args.options{i,1} ','];
        str=[str num2str(args.options{i,2})];
    end % if
end % i

% Call function
eval(str); 

results='done';