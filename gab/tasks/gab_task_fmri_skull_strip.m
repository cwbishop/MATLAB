function results = gab_task_fmri_skull_strip(args)

if ~isfield(args,'thresh')||isempty(args.thresh)
    args.thresh=.2;
end
if ischar(args.file)
    args.file={args.file};
end
if ischar(args.tpm)
    args.tpm={args.tpm};
end

Vm=spm_vol(args.tpm);
Ym=spm_read_vols([Vm{:}]);
msk=sum(Ym,4)>args.thresh;

for f=1:length(args.file)
    V=spm_vol(args.file{f});
    Y=spm_read_vols(V);
    Y(~msk)=0;
    
    Vout=rmfield(V,'pinfo');
    [path,fname,extt]=fileparts(V.fname);
    Vout.fname=fullfile(path, ['ss_' fname extt]);
    spm_write_vol(Vout,Y);
end

results='done';