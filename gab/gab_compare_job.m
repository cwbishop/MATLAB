function status=gab_compare_job(newJob, oldJob)
%we want to check a new job against an old job. If they are different, we
%want to know that, otherwise, we just return the status of the old job

if ischar(newJob)
    newJob=load(newJob);
    newJob=newJob.job;
end
newJob=gab_clean_job(newJob);

%if the job file doesn't already exist, it is a new job
if ischar(oldJob)
    if ~exist(oldJob,'file')
        status='new';
        return
    end
    oldJob=load(oldJob);
    oldJob=oldJob.job;
end

%if the job file exists, but anything has been changed, it is a modified
%job
if length(newJob.task) ~= length(oldJob.task)
    status='modified';
    return
end  
if ~cellcmp(newJob.task,oldJob.task) || ~cellcmp(newJob.parent,oldJob.parent) || ~strcmp(newJob.jobName,oldJob.jobName) || ~strcmp(newJob.jobDir,oldJob.jobDir)
    status='modified';
    return
end

%if we've gotten to this point, just report the oldJob's status
status=oldJob.status;

function pass = cellcmp(x,y)
%because matlab doesn't have an inbuilt cell comparison function...

pass=true;

if length(x) ~= length(y)
    pass=false;
    return
end

for n=1:length(x)
    if ~strcmp(class(x{n}),class(y{n}))
        pass=false;
        return
    end
    switch class(x{n})
        case 'struct'
            pass=structcmp(x{n},y{n});
        case 'cell'
            pass=cellcmp(x{n},y{n});
        case 'char'
            pass=strcmp(x{n},y{n});
        case 'function_handle'
            pass=strcmp(func2str(x{n}),func2str(y{n}));
        otherwise
            if ndims(x{n})==ndims(y{n}) && all(size(x{n})==size(y{n}))
                pass=all(eq(x{n},y{n}));
            else
                pass=false;
            end
    end
    if ~pass
        return
    end
end

function pass = structcmp(x,y)
%because matlab doesn't have an inbuilt structure comparison function...

pass=true;

x=orderfields(x);
y=orderfields(y);

xfieldnames=fieldnames(x);
yfieldnames=fieldnames(y);

if ~cellcmp(xfieldnames,yfieldnames);
    pass=false;
    return
end
if length(x) ~= length(y)
    pass=false;
    return
end

for a=1:length(x)
    for n=1:length(xfieldnames)
        if ~strcmp(class(x(a).(xfieldnames{n})),class(y(a).(yfieldnames{n})))
            pass=false;
            return
        end
        switch class(x(a).(xfieldnames{n}))
            case 'struct'
                pass=structcmp(x(a).(xfieldnames{n}),y(a).(xfieldnames{n}));
            case 'cell'
                pass=cellcmp(x(a).(xfieldnames{n}),y(a).(xfieldnames{n}));
            case 'char'
                pass=strcmp(x(a).(xfieldnames{n}),y(a).(xfieldnames{n}));
            case 'function_handle'
                pass=strcmp(func2str(x(a).(xfieldnames{n})),func2str(y(a).(xfieldnames{n})));
            otherwise
                if ndims(x(a).(xfieldnames{n}))==ndims(y(a).(xfieldnames{n})) && all(size(x(a).(xfieldnames{n}))==size(y(a).(xfieldnames{n})))
                    pass=all(eq(x(a).(xfieldnames{n}),y(a).(xfieldnames{n})));
                else 
                    pass=false;
                end
        end
        if ~pass
            return
        end
    end
end