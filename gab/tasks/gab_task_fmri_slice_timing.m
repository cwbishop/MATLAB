function results = gab_task_fmri_slice_timing(args)
%gab wrapper for spm_slice_timing

%clever little way to define a bunch of defaults easily. Taken from spm
defArgs = struct('filt',{repmat({'^\d.*\.nii'},size(args.data))},'TA',args.TR-args.TR/length(args.so),'refslice',2,'prefix','a');
fnms = fieldnames(defArgs);
for i=1:length(fnms),
    if ~isfield(args,fnms{i}),
        args.(fnms{i}) = defArgs.(fnms{i});
    end
end

%compute the timing values spm wants
nslices=length(args.so);
timing(2) = args.TR - args.TA;
timing(1) = args.TA / (nslices - 1);

%if we have folders as others, we want to get all of the files in the
%folder, but each folder in it's own cell to denote time boundaries
data={};
for s=1:length(args.data)
    if isdir(args.data{s})
        files=spm_select('list',args.data{s},args.filt{s});
        temp={};
        for f=1:size(files,1)
            temp=[temp fullfile(args.data{s},files(f,:))];
        end
        data=[data strvcat(temp{:})];
    else
        data=[data args.data(s)];
    end
end

for s=1:length(data)
    spm_slice_timing(data{s},args.so,args.refslice,timing,args.prefix);
end

results='done';
