function newJob=gab_clean_job(job)
%gives your job that fresh and clean scent
%
%Really, just prunes fields that might have accumulated due to sucsessful
%or attempted runs. useful when rerunning jobs

newJob=gab_emptyjob;

fields={'jobDir','jobName','parent','task'};
    
for f=1:length(fields)
    newJob.(fields{f})=job.(fields{f});
end

%update hashes for task functions
for t=1:length(newJob.task)
    newJob.task{t}=gab_get_hashes(newJob.task{t});
end