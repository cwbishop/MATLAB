function results = gab_task_fmri_run_model(args)

%load defaults
defaults = spm('Defaults','fmri');

if ~iscell(args.scans)
    args.scans={args.scans};
end
if ~isfield(args,'scanFilt')||isempty(args.scanFilt)
    args.scanFilt='^swra.*\.nii';  %match that at the end of the file name
end
if ~isfield(args,'covariates')||isempty(args.covariates)
    args.covariates = args.dir; %default to same dir that we will have our spm struct in
end
if ~isfield(args,'covFilt')||isempty(args.covFilt)
    args.covFilt='$sess\dcov\.mat';  
end
if ~isfield(args,'nuFilt')||isempty(args.nuFilt)
    args.nuFilt='^rp_a001\.txt';  %match that at the beginning of the file name
end
if ~isfield(args,'mask')||isempty(args.mask)
    args.mask={''};  %default to no mask
end
if ~isfield(args,'gnorm')||isempty(args.gnorm)
    args.gnorm='none';  %default to no normalization
end
if ~isfield(args,'fact')||isempty(args.fact)
    args.fact=struct('name',cell(0,0),'levels',cell(0,0));  %default to no factor interaction
end

check_dir(args.dir);
if exist(fullfile(args.dir,'SPM.mat'),'file')
    delete(fullfile(args.dir,'SPM.mat'))
end

%if our scans are directories, we need to have one cell for each dir
for s=1:length(args.scans)
    if ischar(args.scans{s}) && isdir(args.scans{s})
        files=spm_select('list',args.scans{s},args.scanFilt);
        temp={};
        for f=1:size(files,1)
            temp=[temp fullfile(args.scans{s},files(f,:))];
        end
        args.scans{s}=temp; %add it in as a cell array inside a cell for how cells deal into structures
    end
end

if isfield(args,'oneSess') && args.oneSess
    args.scans={[args.scans{:}]};
end

%if our regressors are directories, we need to end up with one cell for
%each file, but that file needs to be in a cell
fields={'covariates','nuisance'};
filts={'covFilt','nuFilt'};
for t=1:length(fields)
    if ischar(args.(fields{t})) %if it's a string, put it in a cell
        args.(fields{t})={args.(fields{t})};
    end
    
    temp={};   
    for s=1:length(args.(fields{t}))
        if ischar(args.(fields{t}){s}) && isdir(args.(fields{t}){s})
            files=spm_select('list',args.(fields{t}){s},args.(filts{t}));
            for f=1:size(files,1)
                temp=[temp {{fullfile(args.(fields{t}){s},files(f,:))}}];
            end
        else
            temp={args.(fields{t})};
        end
    end
    args.(fields{t})=temp; %add it in as a cell array inside a cell for how cells deal into structures
end

%figure out bases functions
if ischar(args.bases)
    switch args.bases
        case 'hrf'
            bases=struct('hrf',struct('derivs',[0 0]));
        otherwise %then the name of the field in bases is the string we give it, with an length and order variable.
            bases=struct(args.bases,struct('length',args.bfLen,'order',args.bfOrder));
    end
else
    bases=args.bases;
end

%check to make sure our mask is in a cell
if ischar(args.mask)
    args.mask={args.mask};
end

%build spm job structure
fmri_spec=struct(...
    'dir',{{args.dir}},...
    'timing',struct(...
        'units',args.units,...
        'RT',args.TR,...
        'fmri_t',defaults.stats.fmri.fmri_t,...
        'fmri_t0',defaults.stats.fmri.fmri_t0),...
    'sess',struct(...%beause of the way struct() works, each of our cells will be dealt into its own member of a struct array
        'scans',args.scans,...
        'cond',struct('name',cell(0,0),'onset',cell(0,0),'duration',cell(0,0),'tmod',cell(0,0),'pmod',cell(0,0)),...
        'multi',args.covariates,...
        'regress',struct('name',cell(0,0),'val',cell(0,0)),...
        'multi_reg',args.nuisance,...
        'hpf',defaults.stats.fmri.hpf),...
    'fact',args.fact,...
    'bases',bases,...
    'volt',1,...
    'global',args.gnorm,...
    'mask',{args.mask},...
    'cvi',defaults.stats.fmri.cvi);

if length(fmri_spec.sess)==0
    error('No sessions specified in call to spm_run_fmri_spec!');
end

results = spm_run_fmri_spec(fmri_spec);

cd(args.dir)
load SPM.mat

if isfield(args,'orth')&&args.orth
    if ~isfield(args,'iOrth') || isempty(args.iOrth)
        iOrth=SPM.xX.iC; %if we don't specify which covs, use all the cov of interest (however, spm is dumb and dumps nuisance reg in here)
    else
        iOrth=args.iOrth;
    end
    SPM.xX.X(:,iOrth)=spm_orth(SPM.xX.X(:,iOrth));
end

spm_spm(SPM);
        
function check_dir(dir)
    if ~isdir(dir)
        subdir=fileparts(dir);
        check_dir(subdir);
        mkdir(dir);
    end
    
    
    
    
    
    
    
    
    
    