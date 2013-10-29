function results = gab_task_fmri_svm(args)
%gab wrapper for libsvm http://www.csie.ntu.edu.tw/~cjlin/libsvm/
%This function takes in the path to an SMP data structure file, and runs a
%SVM within that subject. It is built to work with the way SPM deals with
%multi-session data, with separate covariates for each session. A leave-one
%-out design is used across those sessions to determine prediction
%accuracy.
%
%INPUTS:
% args - A structure containing the following fields. optional fields
%        surrounded by ()
%     .spmmat  - The full path to the SPM.mat file to be used.
%     .iBeta   - an index of the covariates to use. For example, if you had
%                three covariates, and wanted to classsify brain states of
%                #2 vs #3, and had 3 sessions then iBeta = [2 3 5 6 8 9];
%     .iGroup  - the group index of the scans used, using the previous
%                example this would be [1 2 1 2 1 2];
%    (.norm)   - Normalization method to use for data across sessions.
%                defaults to standard deviation. See libsvm documentation
%                for rationale behind normalization.
%    (.outFile)- name/path of the output file. relative paths will be
%                placed in the same directory as the SPM.mat file
%                specified. See svm_loo for a description of the output
%                file.
%    (.mask)   - A mask file to select only a subsection of voxels for the
%                analysis.
%

if ~isfield(args,'outFile')||isempty(args.outFile)
    args.outFile='svm.mat';
end
if ~isfield(args,'norm')||isempty(args.norm)
    args.norm='std';
end

indir=pwd;

load(args.spmmat);
cd(SPM.swd);
V=SPM.Vbeta(args.iBeta);
names={SPM.xX.name{args.iBeta}};

for i=1:length(V)

    if any(V(1).mat(:) ~= V(i).mat(:))
        error('Images do not have the same mapping to space');
    end
    if any(V(1).dim ~= V(i).dim)
        error('Images not of the same size');
    end

end

DIM=V(1).dim;

if isfield(args,'mask') && ~isempty(args.mask)
    Vm=spm_vol(args.mask);
    mask=spm_read_vols(Vm)>0;
else
    Vm=[];
    mask=repmat(true,DIM);
end

[x y z]=ind2sub(DIM,find(mask));

XYZ=[x y z]';

data=spm_get_data(V,XYZ);
igood=all(~isnan(data));
data=data(:,igood);
XYZ=XYZ(:,igood); %we'll use this when we figure out how to write SV images

svm = svm_loo(data,args.iGroup,args.norm);

svm.Vdata=V;
svm.names=names;
svm.Vmaks=Vm;
svm.XYZ=XYZ;

save(args.outFile,'svm');

cd(indir);
results='done';        