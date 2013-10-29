function results=gab_task_fmri_chkmot(args)
%function to check the head motion in the epi data after realignment by spm

for s=1:length(args.dir)
    file=dir(fullfile(args.dir{s},'rp_*.txt'));
    mot{s}=load(fullfile(args.dir{s},file.name));
end

save(fullfile(args.savedir,'motion_param.mat'),'mot');

results='done';