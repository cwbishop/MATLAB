function results = gab_task_fmri_smooth(args)

if ~isfield(args,'prefix')||isempty(args.prefix)
    args.prefix='s';
end
if ~isfield(args,'im')||isempty(args.im)
    args.im=1;
end
if ~isfield(args,'filt')||isempty(args.filt)
    args.filt=repmat({'^wra\d.*\.nii'},size(args.data));
end

if ischar(args.data);
    args.data={args.data};
end

%if we have folders as data, we want to get all of the files in the
%folder that match our filter
data={};
for s=1:length(args.data)
    if isdir(args.data{s})
        files=spm_select('list',args.data{s},args.filt{s});
        for f=1:size(files,1)
            data=[data fullfile(args.data{s},files(f,:))];
        end
    else
        data=[data args.data{s}];
    end
end
args.data=data;

args.dtype=0;

%finally, a sensible function, unforunately, it doesn't do any input 
%checking so we needed to do a bit of work before we passed it the args.
spm_run_smooth(args);

results = 'done';

