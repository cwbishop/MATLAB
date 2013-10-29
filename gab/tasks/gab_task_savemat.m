function result=gab_task_savemat(args)
%basic function to save variables in mat files through gab
if ~iscell(args.vars)
    args.vars={args.vars};
end

%any variables you want to save should already be on the global workspace,
%so get them locally with a eval statement
txt='global';
for i=1:length(args.vars)
    txt=[txt ' ' args.vars{i}];
end
eval(txt);

%make sure the directory you want to save to exists
if ~exist(args.path,'dir')
    mkdir(args.path);
end

save(fullfile(args.path,args.file),args.vars{:},'-v7.3'); %for some reason, some of the EEG structs can't be saved in the older format. no idea why, this is the easy fix KH 10/06/25

result='done';