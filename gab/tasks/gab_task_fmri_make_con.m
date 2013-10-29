function results = gab_task_fmri_make_con(args)

if ~iscell(args.spmmat)
    args.spmmat={args.spmmat};
end
if ~isfield(args,'delete')||isempty(args.delete);
    args.delete=1;
end
if ~iscell(args.conName)
    args.conName={args.conName};
end
if ~iscell(args.convec)
    args.convec={args.convec};
end
if ~isfield(args,'sessrep')||isempty(args.sessrep);
    args.sessrep=repmat({'none'},size(args.conName));
end
if ~iscell(args.sessrep)
    args.sessrep={args.sessrep};
end
if ~isfield(args,'stat')||isempty(args.stat);
    args.stat='T';
end

switch args.stat
    case 'T'
        conType='tcon';
    case 'F'
        conType='fcon';
        for c=1:length(args.convec);
            args.convec{c}={{args.convec{c}}};%wow spm is dumb, it needs it as an array if it's a t con and a cell array if it's a fcon.... wtf then using struct will strip off one layer as well...
        end
end
job.spmmat=args.spmmat;
job.delete=args.delete;

for c=1:length(args.conName);
    job.consess{c}.(conType)=struct(...
        'name',args.conName{c},...
        'convec',args.convec{c},...
        'sessrep',args.sessrep{c});
end

spm_run_con(job);

results='done';