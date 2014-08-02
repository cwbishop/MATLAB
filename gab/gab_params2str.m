function str = gab_params2str(params)
%% DESCRIPTION:
%
%   Function to take a cell array of parameters and turn it into a sensible
%   string. This proved useful when using the 'evalin' function to evaluate
%   ERPLAB calls in the base workspace.
%
% INPUT:
%
%   cell array of parameters
%
% OUTPUT:
%
%   str:    string form of parameter (key/val) pairs
%
% Christopher W. Bishop
%   University of Washington
%   8/14

% Get key/val information
% key = params{1:2:end}; % key values
% val = params{2:2:end}; % parameter values

str = []; 

for i=1:length(params)
    
    str = [str ','];
    
    switch class(params{i})
        case {'char'}
            str = [str ''''  params{i} '''']; 
        case {'double', 'single'}
            
            str = [str '[' num2str(params{i}) ']']; 
        otherwise
            error('Do not know what to do with this class');
    end % switch class(params{i});
    
end % for i=1:length(params)
