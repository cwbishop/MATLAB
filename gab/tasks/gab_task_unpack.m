function result = gab_task_unpack(args)
%unpacks .tar.gz'd files (and maybe soon others) and puts them in folders,
%optionally filtering the unpacked contents of each folder with a globbing
%expression
% Hill, KT
%   Modifications by Bishop, CW

if ischar(args.destination)
    args.destination={args.destination};
end

if ~isfield(args,'filter')
    args.filter=cell(size(args.destination));
end

if ischar(args.filter)
    args.filter={args.filter};
end

if ~isfield(args,'options')
    args.options=repmat({''},size(args.destination));
end

%not 100% sure why but you need to cd to the source dir or you might
%get an error
cd(fileparts(args.source));

%% CREATE OTHER DIRECTORIES
% CWB100419
% Added optional input argument to create directories that do not yet have
% anything explicitly placed in them.
if isfield(args, 'directories')
    for d=1:length(args.directories)
        if ~exist(args.directories{d}, 'dir')
            mkdir(args.directories{d});
        end % if 
    end % d
end % isfield

for d=1:length(args.destination)
    if ~exist(args.destination{d},'dir')
        mkdir(args.destination{d});
    end

    %% CWB101231: Introduced try catch and switched error to warning
    %% message
    try
        cmd=sprintf('tar -xzf %s -C %s %s',args.source,args.destination{d},args.options{d});
    
        %if we have a filter, tac it on the end of the command
        if length(args.filter)>=d && ~isempty(args.filter{d})
            cmd = [cmd ' ' args.filter{d}];
        end
    
        [err,out]=unix(cmd);
    catch
        warning([cmd ' failed!']);
        if err
            warning(out);
        end
    end % try
end



result='done';
    