function job=gab_foreman_qsub(job,hjid)
%a job handeling middle man that uses sun grid engine to submit jobs for
%prallalel processing

if isstruct(job) 
    gab_save_job(job);
    job=fullfile(job.jobDir, [job.jobName '.mat']);
end

cmd='qsub '; %this makes a qsub that requires 12gb of free memory. This will mean fewer nodes are usable at a time, but no memory errors.
if exist('hjid','var') && ~isempty(hjid)
    pause(.5);%wait to make sure all previous jobs have been processed by the queue, otherwise we'll get an error...
    cmd=[cmd '-hold_jid '];
    for h=1:length(hjid)
        cmd=[cmd num2str(hjid(h)) ','];
    end
    cmd=cmd(1:end-1);%trim trailing comma
end
cmd=[cmd ' ~/mtlb.sh "gab_run_job(''' job ''');"'];

fprintf(1,'Submitting qsub job: %s\n', job);
[err,outp]=unix(cmd);

%change to struct to record status of qsub
load(job);

if err
    job.status='error';
    job.error.message='Qsub Error';
    job.error.identifier='gab:gab_foreman_qsub:qsubError';
    save(fullfile(job.jobDir, [job.jobName '.mat']),'job');
    fprintf(1,'ERROR: %s\n',outp);
else
    job.status='waiting';
    jid=textscan(outp,'%*s %*s %n');
    job.jid=jid{1};
    save(fullfile(job.jobDir, [job.jobName '.mat']),'job');
    fprintf(1,' Job queued as %d\n',job.jid);
end