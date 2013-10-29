function results=gab_make_corr_mat(args)

cmat=make_corr_mat(args.subs,args.inFiles,args.base);

if ~exist(fileparts(args.outFile),'dir')
    mkdir(fileparts(args.outFile))
end

save(args.outFile,'cmat');
results=cmat;