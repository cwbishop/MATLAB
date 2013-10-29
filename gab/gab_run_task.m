function results = gab_run_task(task)
%This is separated from gab_run_job() pretty much only for debugging or
%running a single task by hand.

%if we pass a path to a task file (NON standard behavior), we need to load
%the task
if ~isstruct(task)
    load(task);
end

%task.func should be a function handle. the reutrn field is mostly for ensemble-tied jobs, but function might be able to be expanded
results=task.func(task.args); 