function result = gab_task_fmri_norm_est(args)
%a small function to write a wrapper for spm_run_coreg_estwrite.m that
%coregisters a set of data with a reference image. make sure spm8/config is
%on your path to allow this to find spm_run_coreg_estwrite.m

%grab defaults for now, possibly overwrite some with args...
defaults=spm('defaults','fmri');

defaults.normalise.estimate.template={args.template};

job=struct('subj',struct('source',{{args.source}},'wtsrc',''),...
    'eoptions',defaults.normalise.estimate);

spm_run_normalise_estimate(job);

result='done';