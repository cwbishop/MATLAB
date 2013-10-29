function gab_save_job(job,fid)
%a safe way to save a job struct. checks for prexisting job file

job=gab_clean_job(job);

if ~exist(fullfile(job.jobDir, [job.jobName '.mat']),'file')
    if ~exist(job.jobDir, 'dir')
        rec_mkdir(job.jobDir)
    end
    save(fullfile(job.jobDir, [job.jobName '.mat']),'job');
else
    cStatus=gab_compare_job(job,fullfile(job.jobDir, [job.jobName '.mat']));
    if strcmp(cStatus, 'modified') && exist('fid','var')
        fprintf(fid,'Job %s/%s.mat modified; Overwriting.\n',job.jobDir, job.jobName);
    end
        
    if any(strcmp(cStatus, {'new','error','modified'}))
        save(fullfile(job.jobDir, [job.jobName '.mat']),'job');
    end
end

function rec_mkdir(dir)

parent=fileparts(dir);
if ~exist(parent, 'dir')
    rec_mkdir(parent);
end

mkdir(dir)
