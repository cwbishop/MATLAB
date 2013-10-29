function results = gab_task_cleanup(args)
%cleans up any directories with crap in them with a wildcard filter

if ~iscell(args.dir)
    args.dir={args.dir};
end
if ~iscell(args.filt)
    args.filt={args.filt};
end

if length(args.filt)==1
    args.filt=repmat(args.filt,size(args.dir));
end

for d=1:length(args.dir)
    cd(args.dir{d})
    unix(['rm ' args.filt{d}]);
end

results='done';