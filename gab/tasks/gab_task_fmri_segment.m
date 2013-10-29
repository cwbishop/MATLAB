function results = gab_task_fmri_segment(args)

defaults = spm('defaults','fmri');

if isfield(args,'gmFiles') && ~isempty(args.gmFiles)
    defaults.preproc.output.GM=args.gmFiles;
end
if isfield(args,'wmFiles') && ~isempty(args.wmFiles)
    defaults.preproc.output.WM=args.wmFiles;
end
if isfield(args,'csfFiles') && ~isempty(args.csfFiles)
    defaults.preproc.output.CSF=args.csfFiles;
end

if ~isfield(args,'mask') || isempty(args.mask)
    args.mask={''};
end

matlabbatch{1}.spm.spatial.preproc= struct(...
    'data',{{args.source}},...
    'output',defaults.preproc.output,...
    'opts',rmfield(defaults.preproc,'output'));

matlabbatch{1}.spm.spatial.preproc.opts.msk=args.mask;

jid=cfg_util('initjob',{matlabbatch});
cfg_util('run',jid);

results = 'done';