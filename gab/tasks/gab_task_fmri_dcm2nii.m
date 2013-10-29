function result = gab_task_fmri_dcm2nii(args)
%A gab task to convert dicom images into other forms (usually nifti) using
%the medcon utility by Eric Nolf
%
%ARGS
% .base - one of the two required arguments, gives the base directory which
%         houses the directories of epi files. This version assumes that
%         the dicom dirs start with a zero padded 3 digit number denoting
%         session number
% .sessions - the other required argument. a cell array of number arrays 
%             that denotes the session numbers for each type of dicom
%             file(s). eg. {[10] [6:9]}. The default is to assume that
%             the first cell are for mprage files, the second for  EPIs.
%             This default is changed by changing the other arguments.
% .destination - The destination directories for the dicoms, should be one
%                each type of file
% .name - cellstr ofname (or base name if multiple files) of the converted
%         images (default: {'mprage','t2','epi'})
% .format - format of output images ( 'img' | 'nii' (default) )

indir = pwd;
cd(args.base);

if ~isfield(args,'destination') || isempty(args.destination)
    args.destination={fullfile(fileparts(args.base),'anatomy'),fullfile(fileparts(args.base),'epi')};
end
if ~isfield(args,'format') || isempty(args.format)
    args.format='nii';
end
if ~isfield(args,'name') || isempty(args.name)
    args.name={'mprage','epi'};
end

if ischar(args.destination)
    args.destination={args.destination};
end

sessDirs=dir('./'); %get the contents of the base dir
sessDirs=sessDirs([sessDirs.isdir]);
sessDirs={sessDirs(3:end).name};

for d = 1:length(args.destination)
    if ~exist(args.destination{d},'dir')
        mkdir(args.destination{d});
    end
    for s = 1:length(args.sessions{d})
        
        sourceDir=[sessDirs{strmatch(sprintf('%03d',args.sessions{d}(s)),sessDirs)} filesep]; %find the index of the session in sessDirs by number, then grab it from sessDirs
        filelist=dir(fullfile(sourceDir,'*.dcm'));
        filelist=strvcat(filelist.name);
        
        P=[repmat(sourceDir,size(filelist,1),1) filelist];

        hdr=spm_dicom_headers(P);
        
        out=spm_dicom_convert(hdr,'all','flat',args.format);
        
        if length(args.sessions{d}) > 1 && length(out.files) > 1 %if we have more than one sess, and more than one file in this sess, we want to use another directory level
            filename=[fullfile(args.destination{d},[args.name{d} num2str(s)]) filesep];
            if ~exist(filename,'dir')
                mkdir(filename);
            end
            
        elseif length(args.sessions{d}) > 1 %if we have more than one sess, but only one file, we still want a sess number on the file
            filename=fullfile(args.destination{d},[args.name{d} num2str(s) '_']);
            
        else %if we only have one session at this destination, just use the name
            filename=fullfile(args.destination{d},args.name{d});
        end
        
        if length(out.files) > 1
            for f=1:length(out.files)
                unix(sprintf('mv -f %s %s%03d.%s',out.files{f},filename,f,args.format)); %force overwrite on the move
            end
                
        else
            unix(sprintf('mv -f %s %s.%s',out.files{1},filename,args.format)); %force overwrite on the move
        end
    end
end

cd(indir);
result='done';
