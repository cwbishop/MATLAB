function result = gab_task_vt_fmri_dcm2nii(args)
%A gab task to convert dicom images into other forms (usually nifti) using
%the medcon utility by Eric Nolf
%
%ARGS
% .source - gives the base directory for the dicom files. Given as a cell
%           array of strings for each file type
% .destination - The destination for the nifti files, should be one
%                each type of file. If there is only one output file (like
%                anatomicals) then the destination is a file name. If there
%                are multiple output files, the destination is created as a
%                folder with numbered images inside.
% .format - format of output images ( 'img' | 'nii' (default) )

indir = pwd;


if ~isfield(args,'format') || isempty(args.format)
    args.format='nii';
end

%replicate base and desitination for the number of filters we have and make
%sure everything is in cell arrays
if ischar(args.source)
    args.source={args.source};
end

if ischar(args.destination)
    args.destination={args.destination};
end

if length(args.source) ~= length(args.destination)
    error('Number of sources and destinations do not match');
end

%now walk through our filters and grab files that match and run them
%through spm_dicom_convert
for d = 1:length(args.destination)
    [sourceBase filt ext]=fileparts(args.source{d});
    filt=[filt ext];
    
    destBase=fileparts(args.destination{d});
    if ~exist(destBase,'dir')
        mkdir(destBase);
    end
    
    cd(destBase);
    
    [err,P]=unix(['find ' sourceBase '/ -name "' filt '"']);
    if err
        error(P)
    end
    P=textscan(P,'%s'); %some silly string parsing to put the output of the unix find command into a format spm likes
    P=char(sort(P{1}));
    
    hdr=spm_dicom_headers(P);
    
    out=spm_dicom_convert(hdr,'all','flat',args.format);
    
    if length(out.files) > 1 %if we have multiple files we want our destination to be a dir and our images to be sequentially numbered inside that dir
        if ~exist(args.destination{d},'dir')
            mkdir(args.destination{d});
        end
        for f=1:length(out.files)
            unix(sprintf('mv -f %s %s%s%03d.%s',out.files{f},args.destination{d},filesep,f,args.format)); %force overwrite on the move
        end
        
    else %if we have only one output file, we don't need dirs
        unix(sprintf('mv -f %s %s.%s',out.files{1},args.destination{d},args.format)); %force overwrite on the move
    end
end

cd(indir);
result='done';
