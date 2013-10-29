function results = gab_task_fmri_image_conj(args)
%join multiple images by logical conjunction

if ~isfield(args,'thresh') || isempty(args.thresh)
    args.thresh = zeros(size(args.files));
end
if ~isfield(args,'thType') || isempty(args.thType)
    args.thType = repmat({@gt},size(args.files));
end

V=spm_vol(strvcat(args.files{:}));
Y=spm_read_vols(V);

for v= 1:length(V)
    func=args.thType{v};
    lY(:,:,:,v)=func(Y(:,:,:,v),args.thresh(v));
end

Yout=all(lY,4);

Vout=rmfield(V(1),'pinfo');
Vout.fname=args.outfile;
Vout.desc='logical conjuntion of multiple masks';

spm_write_vol(Vout,Yout);

results='done';
    
