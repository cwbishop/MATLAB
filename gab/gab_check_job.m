function status=gab_check_job(jobs,fid)

if ~iscell(jobs)
    jobs={jobs};
end

%only write formatted output if you give it a fid (1 for stdout), and that
%fid points to a real open file (~isempty(fopen(fid)))
if exist('fid','var') && ~isempty(fid) && ~isempty(fopen(fid))
    fprintf(fid,'Checking job status:\n STATUS\t\tJOB\n');
end

for j=1:length(jobs)
    %if we are given structures convert into a file string and compare our
    %job stucture to that file
    if isstruct(jobs{j}) 
        jobFile{j}=fullfile(jobs{j}.jobDir, [jobs{j}.jobName '.mat']);
        status{j}=gab_compare_job(jobs{j},jobFile{j});
        
    else %must be job file string
        jobFile{j}=jobs{j};
        
        if ~exist(jobFile{j},'file')
            status{j}='???';
        else
            load(jobFile{j})
            status{j}=job.status;
        end
    end
    
    if exist('fid','var') && ~isempty(fid) && ~isempty(fopen(fid))
        fprintf(fid,' %-15s%s\n',status{j},jobFile{j}); %print the status and path of jobfile
    end
end