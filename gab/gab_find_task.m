function [IND]=gab_find_task(JOB, TNAME, TN)
%% DESCRIPTION:
%
%   Function to locate a task within a job structure. Currently uses a
%   really stupid string matching approach because there doesn't seem to be
%   any other unique identifying information (at least consistent
%   identifying information) across tasks. This will likely come back to
%   haunt CWB.
%
% INPUT:
%
%   JOB:    GAB job structure
%   TNAME:  string, name of function handle the task uses.
%   TN:     integer, the expected number of instances of the task to find
%           within job structure. (default = 1);
%
% OUTPUT:
%   
%   IND:    integer, index values for task(s).
%
% Christopher W. Bishop
%   University of Washington
%   2/14

%% OUTPUT
IND=[]; 

%% IDENTIFY TASKS THAT NEED TO BE CHANGED

% Loop through tasks
for i=1:length(JOB.task)
        
    % Does task use specified function?
    if strcmp(func2str(JOB.task{i}.func), TNAME)
        % Append index to array
        IND=[IND i]; 
    end % strcmp
        
end % i    

%% THROW AN ERROR
if length(IND)~=TN, error('Found a different number of tasks than expected'); end 