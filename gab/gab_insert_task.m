function job=gab_insert_task(job, task, ind)
%% DESCRIPTION
%
%   Insert task into GAB job structure
%
% INPUT:
%
%   job:    job structure
%   task:   task structure
%   ind:    where the task should be inserted in the task list. (e.g.,
%           ind=2 means the task will be ultimately be the second task in
%           the job.
%
% OUTPUT:
%
%   job:    modified job structure with inserted task.
%
% Bishop, Christopher W.
%   UC Davis/University of Washington 
%   Miller Lab 2011
%   Tremblay Lab 2013
%   cwbishop@uw.edu

    %% COPY HEADER INFO
    tjob=gab_emptyjob;
    tjob.jobName=job.jobName;
    tjob.jobDir=job.jobDir;
    tjob.parent=job.parent;
    
    %% INSERT TASK
    for i=1:length(job.task)        
        if i==ind
            tjob.task{end+1}=task;
            tjob.task{end+1}=job.task{i};
        else
            tjob.task{end+1}=job.task{i};
        end % if
    end % i   
    
    %% COPY MODIFIED JOB
    job=tjob;
end % INSERT_TASK