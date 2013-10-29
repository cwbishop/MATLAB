function gab_qsub_clear(jobs)
%simple little script to kill any jobs that might still report as waiting
%or running. Only run this when all input jobs should be finished.

for j = 1:length(jobs)
    jobFile = fullfile(jobs{j}.jobDir,[jobs{j}.jobName '.mat']);
    load(jobFile);
    switch job.status
        case {'running','waiting'}
            
            fprintf(1,'Killing job %s because it is still %s.\n',jobFile, job.status);
            
            unix(sprintf('qdel %d',job.jid));
            delete(jobFile);
    end
end

    