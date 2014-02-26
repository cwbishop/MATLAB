function [JOB]=gab_replace_task_args(JOB, TASK, ARGS, JNAME)
%% DESCRIPTION:
%
%   Function to replace specific arguments of a task within a job
%   structure. This is currently done in a semi dumb way since tasks do not
%   themselves have names.  So, in order to pull out a task, I attempt to
%   string match the function handle of the task with the function name
%   input (TASK).  This obviously isn't a fool proof approach, but since
%   we do not have any other unique information to go on, I think this is
%   the best we can do. 
%
% INPUT:
%
%   JOB:    GAB job structure
%   TASK:   Function name used in the task(s) of interest. Alternatively,
%           TASK can be an integer array (e.g., [2 4]) specifying which
%           tasks to modify. 
%   ARGS:   Argument structure.  Fields in JOB.task{whatever}.args are
%           replaced with ARGS.{the stuff you want to change}
%
%   JNAME:  String, new name for job. If not provided, the name isn't
%           changed.
%
% OUTPUT:
%
%   JOB:   Job structure with modified tasks.
%
%

%% IS TASK AN ARRAY OR A STRING?
if isa(TASK, 'double'), IND=TASK; else IND=[]; end 

%% CHANGE JOB NAME?
if exist('JNAME', 'var') && ~isempty(JNAME), JOB.jobName=JNAME; end 

%% IDENTIFY TASKS THAT NEED TO BE CHANGED
if isempty(IND)
    
    % Loop through tasks
    for i=1:length(JOB.task)
        
        % Does task use specified function?
        if strcmp(func2str(JOB.task{i}.func), TASK)
            % Append index to array
            IND=[IND i]; 
        end % strcmp
        
    end % i
    
end % isempty IND

%% CHANGE ARGS OF TASKS

% Loop through INDEX (IND)
for i=1:length(IND)
    
    % Get field names of ARGS input
    FNAMES=fieldnames(ARGS);
    
    % REPLACE JOB.task.args with values
    for z=1:length(FNAMES)
        JOB.task{IND(i)}.args.(FNAMES{z}) = ARGS.(FNAMES{z});
    end % z=1:length(FNAMES)
    
end % i