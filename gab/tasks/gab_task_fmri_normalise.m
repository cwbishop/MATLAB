function result = gab_task_fmri_normalise(args)
%a small function to write a wrapper for spm_run_coreg_estwrite.m that
%coregisters a set of data with a reference image. make sure spm8/config is
%on your path to allow this to find spm_run_coreg_estwrite.m

%grab defaults for now, possibly overwrite some with args...
defaults=spm('defaults','fmri');

if ~isfield(args,'filt')||isempty(args.filt)
    args.filt=repmat({'^cra\d.*\.nii'},size(args.resample));
end
if isfield(args,'prefix')&&~isempty(args.prefix)
    defaults.normalise.write.prefix=args.prefix;
end
if isfield(args,'bb')&&~isempty(args.bb)
    defaults.normalise.write.bb=args.bb;
end
if isfield(args,'vox')&&~isempty(args.vox)
    defaults.normalise.write.vox=args.vox;
end
defaults.normalise.estimate.template={args.template};

%if we have folders as resample targets, we want to get all of the files in
%the folder that match our filter
resample={};
for s=1:length(args.resample)
    if isdir(args.resample{s})
        files=spm_select('list',args.resample{s},args.filt{s});
        for f=1:size(files,1)
            resample=[resample fullfile(args.resample{s},files(f,:))];
        end
    else
        resample=[resample args.resample{s}];
    end
end

job=struct('subj',struct('source',{{args.source}},'resample',{resample},'wtsrc',''),...
    'roptions',defaults.normalise.write,'eoptions',defaults.normalise.estimate);

spm_run_normalise_estwrite(job);

result='done';