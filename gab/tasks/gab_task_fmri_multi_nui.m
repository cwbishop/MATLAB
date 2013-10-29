function results = gab_task_fmri_multi_nui(args)
%

if ~isfield(args,'filt') || isempty(args.filt)
    args.filt='^rp_a001.txt';
end
if ~isfield(args,'sessCovs') || isempty(args.sessCovs)
    args.sessCovs=[1 1];
end

R=[];

if ischar(args.dir)
    args.dir={args.dir};
end

for d=1:length(args.dir)
    
    if isdir(args.dir{d})
        temp=spm_select('list',args.dir{d},args.filt);
        for f=1:size(temp,1)
            files(f,:)=fullfile(args.dir{d},temp(f,:));
        end
    else
        files=args.dir{d};
    end
    
    for f=1:size(files,1)
        temp=importdata(files(f,:));
        
        if args.sessCovs(1) %session mean cov
            temp=[temp ones(size(temp,1),1)];
        end
        if args.sessCovs(2) %session drift cov
            temp=[temp linspace(-1, 1, size(temp,1))'];
        end
        
        R(end+1:end+size(temp,1),end+1:end+size(temp,2))=temp;
        
    end
end

save(args.outFile,'R');
        
results='done';

        
    
    
    
