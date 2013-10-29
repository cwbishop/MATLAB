function job=gab_foreman_pbs_qsub(job,hjid)
%a job handeling middle man that uses sun grid engine to submit jobs for
%prallalel processing

if isstruct(job) 
    gab_save_job(job);
else
    load(job)
end

jobfile=fullfile(job.jobDir, [job.jobName '.mat']);

cmd=['qsub -N ' job.jobName ' -v CMD_TO_RUN="\"gab_run_job(''' jobfile ''')\""'];
if exist('hjid','var') && ~isempty(hjid)
    pause(.5);%wait to make sure all previous jobs have been processed by the queue, otherwise we'll get an error...
    cmd=[cmd ' -W depend=afterany'];
    for h=1:length(hjid)
        cmd=[cmd ':' num2str(hjid(h))];
    end
end
cmd=[cmd ' ~/mtlb.sh'];

fprintf(1,'Submitting qsub job: %s\n', jobfile);
[err,outp]=unix(cmd);

%change to struct to record status of qsub

if err
    job.status='error';
    job.error.message='Qsub Error';
    job.error.identifier='gab:gab_foreman_qsub:qsubError';
    save(fullfile(job.jobDir, [job.jobName '.mat']),'job');
    fprintf(1,'ERROR: %s\n',outp);
else
    job.status='waiting';
    jid=textscan(outp,'%n %*s', 'delimiter','.');
    job.jid=jid{1};
    save(fullfile(job.jobDir, [job.jobName '.mat']),'job');
    fprintf(1,' Job queued as %d\n',job.jid);
end