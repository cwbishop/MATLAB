function result = gab_task_fmri_realign(args)
%a small function to write a wrapper for spm_run_coreg_estwrite.m that
%coregisters a set of data with a reference image. make sure spm8/config is
%on your path to allow this to find spm_run_coreg_estwrite.m

%grab defaults for now, possibly overwrite some with args....
defaults=spm('defaults','fmri');

if ~isfield(args,'filt')||isempty(args.filt)
    args.filt=repmat({'^a\d.*\.nii'},size(args.data)); %default to grabbing timing corrected images
end

%if we have folders as others, we want to get all of the files in the
%folder. If we have multiple cells in .data then each cell will be treated
%as a separate session by spm (so separate motion param file, etc)
data={};
for s=1:length(args.data)  
    if length(args.data(s))==1 %then we'll assume its a directory
        files=spm_select('list',args.data{s},args.filt{s});
        for f=1:size(files,1)
            data{s}{f}=fullfile(args.data{s},files(f,:));
        end 
    else
        data{s}=args.data{s};
    end
    
end

job=struct('data',{data},...
    'roptions',defaults.realign.write,...
    'eoptions',defaults.realign.estimate);

spm_run_realign_estwrite(job);


%if we have a cleanfirst flag, delete the 'realigned' version of the first
%file
if isfield(args,'cleanfirst')&&args.cleanfirst
    file=fullfile(pathstr,[job.roptions.prefix filename extt]);
    delete(file);
end

result='done';