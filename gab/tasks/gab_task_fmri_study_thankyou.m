function results = gab_task_fmri_study_thankyou(args)
%makes some nice little .bmps to give to subjects after all preproc steps
%are done (at least coreg)

if length(args.vox) == 1
    args.vox = repmat(args.vox,1,3);
end
if ~isfield(args,'slice') || isempty(args.slice)
    args.slice=[86 127 106];
end

[path file extt]=fileparts(args.file);
cd(path);
V=spm_vol(args.file);

%make an evenly spaced grid that goes through our bounding box at our voxel
%resolution
[x,y,z]=meshgrid(args.bb(1,1):args.vox(1):args.bb(1,2), args.bb(2,1):args.vox(2):args.bb(2,2), args.bb(3,1):args.vox(3):args.bb(3,2));

xyz=[x(:)';y(:)';z(:)';ones(1,numel(x))];

XYZ=spm_inv(V.mat)*xyz;

img=reshape(spm_sample_vol(V,XYZ(1,:),XYZ(2,:),XYZ(3,:),2),size(x));
img=permute(img,[2 1 3]);

Vout=rmfield(V,'pinfo');
Vout.fname=['hr_' file extt];
Vout.mat=diag([args.vox 1]);
Vout.mat(1:3,4)=args.bb(:,1);
Vout.dim=size(img);
spm_write_vol(Vout,img);

sag = flipud((squeeze(img(args.slice(1),:,:)))');
sag = sag./max(max(sag));
cor = flipud((squeeze(img(:,args.slice(2),:)))');
cor = cor./max(max(cor));
axi = flipud((squeeze(img(:,:,args.slice(3))))');
axi = axi./max(max(axi));

imwrite(sag,fullfile(path,'sagittal.bmp'),'bmp');
imwrite(cor,fullfile(path,'coronal.bmp'),'bmp');
imwrite(axi,fullfile(path,'axial.bmp'),'bmp');

results='done';
    