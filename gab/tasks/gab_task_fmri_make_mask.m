function results = gab_task_fmri_make_mask(args)
%make a mask from an image, optionally thresholded at some value other than
%zero, then write the data with an specified file name

if ~isfield(args,'thresh')||isempty(args.thresh)
    args.thresh=0;
end

V=spm_vol(args.file);
Y=spm_read_vols(V);
Yout=Y>args.thresh;

[path filename extt] = fileparts(args.file);
if ~isfield(args,'outputName')||isempty(args.outputName)
    outputName=fullfile(path,['masked_' filename extt]);
else
    outputName=args.outputName;
end

Vout=rmfield(V,'pinfo');
Vout.fname=outputName;
spm_write_vol(Vout,Yout);

results = 'done';