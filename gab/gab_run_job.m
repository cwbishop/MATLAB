function job=gab_run_job(job)
%run a job and handle any errors the job runs into
try
    %if we pass a job struct, we need to save it (safely)
    if isstruct(job)
        gab_save_job(job,1);
        job=fullfile(job.jobDir,[job.jobName '.mat']);
    end
    
    if ~exist(job,'file')
        fprintf(1,'Aborting run of %s because job file does not exist.\n', job);
        return
    end
    
    load(job); %yes, we migtht save then reload a job wasting disk IO, but it's safest
    cStatus=job.status;

    switch cStatus
        case {'error','new','waiting','modified'} %we need to run it.

            %check to see if there are parents, and what their current status is
            if isfield(job,'parent')
                for p=1:length(job.parent)
                    try
                        parent=load(job.parent{p});
                        parent=parent.job;
                    catch %if the parents aren't there, we have an error
                        error('Error using ==> load\nUnable to read parent job %s: No such file.',fullfile(job.jobDir,[job.jobName '.mat']));
                    end
                    if any(~strcmp(parent.status,'finished')) %if any of the parents aren't finished, abort
                        error('Unfinsihed parent (%s) with status of %s\n',job.parent{p},parent.status);
                    end
                end
            end

            fprintf(1,'Attempting to run %s.mat\n',fullfile(job.jobDir,job.jobName));
            
            %if we get here, everything is set to start the job
            job.status = 'started';
            job.runTime = now;
            save(fullfile(job.jobDir,[job.jobName '.mat']),'job');

            %a job simply consists of doing all of the tasks in a job in order
            for t=1:length(job.task)
                cd(job.jobDir); %this line is probably not critical
                job.results{t}=gab_run_task(job.task{t});
                save(fullfile(job.jobDir,[job.jobName '.mat']),'job');
            end

            %finish up job and save
            job.status = 'finished';
            %pause(5); %wait 5 seconds for cacheing issues
            save(fullfile(job.jobDir,[job.jobName '.mat']),'job');

        case {'finished','started'} %we shouldn't try to run
            fprintf(1,'Aborting run of %s because job is already %s.\n', fullfile(job.jobDir,[job.jobName '.mat']), cStatus);
            if exist('oldJob','var')
                job=oldJob;
            end
            return
        otherwise %something went ary
            error('Unknown status of type %s',cStatus);
    end
        
catch %if something goes wrong, we need to signal that we had an error

    job.status='error';
    job.error=lasterror;
    %pause(5); %wait 5 sec for cacheing issues
    save(fullfile(job.jobDir,[job.jobName  '.mat']),'job');
    rethrow(lasterror)
end