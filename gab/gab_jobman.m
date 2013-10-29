function gab_jobman(jobs,foreman)
%the true workhorse of gab, this handles jobs in an (hopefully) intelligent
%way. you can either give it a list of jobFiles to run or even more
%conviently, you can just give it the jobStructs such as the output of a
%study_gab_setup function and it will check for jobFiles for you

if ~exist('foreman','var')||isempty(foreman)
    %foreman decides how the jobs are run. A sun-grid-engine based foreman
    %and a basic foreman are presented, but you system may be optomized
    %by writing your own foreman
    foreman=@gab_foreman_pbs_qsub; %this default foreman is a sun-grid engine based foreman that uses qsub.
%     foreman=@gab_run_job; %use this line and comment line above if you want to run the jobs directly in the current matlab window
end

if ~iscell(jobs)
    jobs={jobs};
end

%if we are given structures, save and convert into file strings
for j=1:length(jobs)
    if isstruct(jobs{j})
        gab_save_job(jobs{j},1) %the 1 prints out a line to the console if any jobs were modified
        jobs{j}=fullfile(jobs{j}.jobDir, [jobs{j}.jobName '.mat']);
    end
end
%now we assume that all job file do exist

%now check to make sure all our jobs exist, and if they are already
%finished/started/waiting
keep=repmat(true,1,length(jobs));
for j=1:length(jobs)
    if ~exist(jobs{j},'file')
        error('Job file %s does not exist.',jobs{j});
    else
        load(jobs{j})
        if ~isempty(job.parent)
            pStatus=gab_check_job(job.parent);
        else
            pStatus='finished'; %a bit kludgy, but if there are no parents, then they are 'finished'
        end
        %we don't want to try and handle jobs that are already midway
        %through the process or done
        if any(strcmp(job.status,{'waiting','started'})) || (strcmp(job.status,'finished') && all(strcmp('finished',pStatus)))
            display(['Skipping job ' jobs{j} ' because it is already ' job.status]);
            keep(j)=false;
        end
    end
end
jobs=jobs(keep);

%loop through jobs until we have none left
loopsToLive=length(jobs)+5; %even if we give jobs in exact opposite order, the sorting and queing can't take this long
while ~isempty(jobs)
    keep=repmat(false,length(jobs)); %by default, we will assume all jobs are delt with, unless we figure otherwise later (see line 121&122)
    
    for j=1:length(jobs)
        load(jobs{j});

        if isempty(job.parent) %if there are no parents, then just run it and (plan to) forget about it
            foreman(jobs{j});
            keep(j)=false;
        else %next step is to check the parents, this is a pain because of all of the different states each parent can be in....
            pStatus=gab_check_job(job.parent);

            %turn status into a series of binary flags
            hI=strcmp('started',pStatus)|strcmp('waiting',pStatus);
            fI=strcmp('finished',pStatus);
            nI=strcmp('new',pStatus);
            eI=~(hI|fI|nI); %if it's not one of those, it's an error

            %check for a couple of likely errors
            if any(eI)  %if any parent has an error, this job can't be run
                eParents=job.parent(eI);
                eStatus=pStatus(eI);
                msg='Error in parent(s):\n STATUS\t\tPARENT\n';
                for e=1:length(eParents)
                    msg=[msg ' ' eStatus{e} '\t'];
                    if length(eStatus{e})<7
                        msg=[msg '\t'];
                    end
                    msg=[msg eParents{e} '\n'];
                end
                job.status='error';
                job.error.message=msg;
                job.error.identifier='gab:gab_jobman:parentError';
                save(fullfile(job.jobDir, [job.jobName '.mat']),'job');

            %I think this elseif should be moved inside gab_foreman_qsub
            %because it relies on sge elements
            elseif any(hI) %if there are qued jobs, we need to check to make sure those qued jobs have jid's
                hjid=[];
                hParents=job.parent(hI);
                for h=1:length(hParents)
                    parent=load(hParents{h});
                    if isfield(parent.job,'jid') && ~isempty(parent.job.jid) && parent.job.jid>0
                        hjid(h)=parent.job.jid;
                    else
                        hjid(h)=nan;
                    end
                end

                %need to make sure each of our jids is valid
                if any(isnan(hjid))
                    heParents=hParents(isnan(hjid));
                    message='No jid for parent(s): ';
                    for he=1:length(heParents)
                        message=[message heParents{he} ' '];
                    end
                    job.status='error';
                    job.error.message=message;
                    job.error.identifier='gab:gab_jobman:parentJidError';
                    save(fullfile(job.jobDir, [job.jobName '.mat']),'job');

                else %we can run with holds
                    foreman(jobs{j},hjid);
                end

            elseif all(fI) %if everything is done, just run it without holds
                foreman(jobs{j});

            else %must have new parent, hopefully, the parent just exists later in this same job list, so keep it around for awhile
                keep(j)=true;

            end
        end
    end
    
    %forget jobs that should be forgotten, only jobs with new parents
    %should be kept
    jobs=jobs(keep);
    
    loopsToLive=loopsToLive-1;
    
    if ~loopsToLive && length(jobs) %this is to prevent infinite looping looking for jobs parents that stay 'new' forever.
        for j=1:length(jobs)
            job=load(jobs{j});
            job=job.job;
            job.status='error';
            job.error.message='Looks like an infinite loop... likely there is a new parent which is not attempting to run';
            job.error.identifier='gab:gab_jobman:tooManyLoops';
            save(fullfile(job.jobDir, [job.jobName '.mat']),'job');
        end
        return
    end
end     