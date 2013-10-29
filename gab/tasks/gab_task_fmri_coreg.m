function result = gab_task_fmri_coreg(args)
%a small function to write a wrapper for spm_run_coreg_estwrite.m that
%coregisters a set of data with a reference image. make sure spm8/config is
%on your path to allow this to find spm_run_coreg_estwrite.m

%grab defaults for now, possibly overwrite some with args...
defaults=spm('defaults','fmri');

if ~isfield(args,'other')
    args.other=[];
end
if ~isfield(args,'filt')||isempty(args.filt)
    args.filt=repmat({'ra\d.*\.nii'},size(args.other));
end

%if we have folders as others, we want to get all of the files in the
%folder
other={};
for s=1:length(args.other)
    if isdir(args.other{s})
        files=spm_select('list',args.other{s},args.filt{s});
        for f=1:size(files,1)
            other=[other fullfile(args.other{s},files(f,:))];
        end
    else
        other=[other args.other{s}];
    end
end

%now just double check that our others aren't also the source
i=true(size(other));
for s=1:numel(other)
    if strcmp(args.source,other{s})
        i(s)=false;
    end
end
other=other(i);
if isempty(other)
    other={''};
end

job=struct('ref',{args.ref},'source',{{args.source}},'other',{other},...
    'eoptions',defaults.coreg.estimate);

spm_run_coreg_estimate(job);

result='done';