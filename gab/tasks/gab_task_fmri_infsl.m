function results=gab_task_fmri_infsl(args)
%compute the mahalanobis distance for contrast as a roving search light
%through a brain

indir=pwd;

load(args.spmmat,'SPM')

cd(SPM.swd);

%create our contrast vector, making sure to apply it to each session
C=zeros(length(args.convec),size(SPM.xX.X,2));
for c=1:length(args.convec)
    for s=1:length(SPM.Sess);
        icol=find(args.convec{c});
        C(c,SPM.Sess(s).col(icol))=args.convec{c}(icol);
    end
end

%only need if no mask used
DIM=SPM.xVol.DIM';
voxSize_mm=abs(diag(SPM.xVol.M));
voxSize_mm=voxSize_mm(1:3);
rad_v=args.slRmm./voxSize_mm;
ctrRelSphereSUBs=build_searchlight('sphere',rad_v);

islm=repmat(nan,[DIM size(C,1)]);

Ivol=sub2ind(DIM,SPM.xVol.XYZ(1,:),SPM.xVol.XYZ(2,:),SPM.xVol.XYZ(3,:)); %get the (I)ndex of valid spm (vol)ume voxels

%if we have a mask, use it, otherwise, make an all true 'mask'
if ~isfield(args,'mask')||isempty(args.mask);
    mask=repmat(true,DIM);
else
    Vm=spm_vol(args.mask);
    mask=spm_read_vols(Vm)>0;
end
Imask=find(mask);

ItV=intersect(Imask,Ivol); %find (I)ndex of (t)est (V)oxels, which are voxels inside both mask and brain

if ~isfield(args,'delete')||isempty(args.delete)
    args.delete=true;
end

mtV=repmat(false,1,prod(DIM));mtV(ItV)=true; %logical (m)ap of (t)est (V)oxels
tVl(mtV)=1:numel(ItV); %(t)est (V)oxel (l)ookup, to find a member of ItV from whole volume index: tVl(ItV(i)) = i
[x y z]=ind2sub(DIM,ItV); %get XYZ of test voxels
XYZ=[x;y;z];

display('  Loading data');

Y = spm_get_data(SPM.xY.VY,XYZ);
Y = spm_filter(SPM.xX.K,SPM.xX.W*Y); %get filtered data

display('  Computing Residuals');
R = spm_sp('r',SPM.xX.xKXs,Y);

clear Y

eB=spm_get_data(strvcat(SPM.Vbeta.fname),XYZ);

display('  Running Searchlight');
%%%%Walk though test voxels%%%
for cV=1:length(ItV) %(c)urrent (V)oxel number

    %display(['Voxel ' num2str(cV) '/' num2str(length(ItV))]);
    % compute subindices of (V)oxels currently illuminated by the (s)earch(l)ight
    Vsl=repmat(XYZ(:,cV),[1 size(ctrRelSphereSUBs,2)])+ctrRelSphereSUBs;

    % exclude out-of-volume voxels
    Vsl=Vsl(:,all(Vsl>0) & all(Vsl <= repmat(DIM',1,size(Vsl,2))));

    %Move to index space (whole volume index)
    Isl=sub2ind(DIM,Vsl(1,:),Vsl(2,:),Vsl(3,:));

    %select just voxels also in test voxels, then lookup their index in ItV
    Isl=tVl(Isl(mtV(Isl)));

    % note how many voxels contributed to this locally multivariate stat
    n(cV)=length(Isl);

    %compute covariance of residuals
    covR=cov(R(:,Isl));

    %get the inverse, we believe this is used to remove
    %the effect of covariance in the noise on the
    %contrast KH&LM 06/08
    icovR=inv(covR);

    rawEffects=C*eB(:,Isl); % contrast by searchlight-space

    %compute (i)nformation (s)earch(l)ight (m)ap using mahalanobis distance divided by the number of searchlight voxels
    islm(x(cV),y(cV),z(cV),:)=diag(rawEffects*icovR*rawEffects')/n(cV); %n can be less than the number of searchlight voxels: when the searchlight includes out-of-mask voxels
end

display('  Writing Results');

%do some slightly kludgy things to let us keep old contrasts if we want
if args.delete
    iC=1:size(islm,4);
    SPM.xCon=[];
else
    iC=[1:size(islm,4)]+length(SPM.xCon);
end

%counter for our infsl contrasts
cCount=1;

for c=iC;
    %setup output structure
    Vout=struct('fname',sprintf('con_%04d.img',c),...
        'mat',SPM.xY.VY(1).mat,'dim',DIM,'dt',SPM.xY.VY(1).dt,...
        'descrip',[args.conName{cCount} ': Mahalanobis distance w/ searchlight radius = ' num2str(args.slRmm) 'mm']);
    Vout=spm_write_vol(Vout,islm(:,:,:,cCount));
    SPM.xCon(c).name=args.conName{cCount};
    SPM.xCon(c).STAT='MD';
    SPM.xCon(c).c=C(cCount,:);
    SPM.xCon(c).Vcon=Vout;
    SPM.xCon(c).Vspm=[];
    
    cCount=cCount+1;
end
save('SPM.mat','SPM');

cd(indir);

results = 'done';

