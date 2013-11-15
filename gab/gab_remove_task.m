function job = gab_remove_task(job, tasknum)
%% DESCRIPTION:
%
%   Removes a task from a job structure.
%
% INPUT:
%   job:    gab job structure
%   tasknum:    integer, task number(s) to remove
%
% OUTPUT:
%   job:    modified job with task(s) removed
%
% Bishop, Christopher
%   University of Washington
%   11/2013

task=job.task;
TASK={}; % updated task list
for i=1:length(task)
    
    % If the task should be included
    if ~ismember(i, tasknum)
        TASK{end+1}=task{i}; 
    end % 
    
end % for i=1:length(tasks)

% Reassign tasks
job.task=TASK; 