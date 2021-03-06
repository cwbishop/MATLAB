function task=gab_get_hashes(task)
%% DESCRIPTION:
%
%   An important part of GAB's functionality is its ability to determine
%   when a job or set of jobs needs to be rerun. Jobs often need to be
%   rerun if the functions themselves have changed. Comparing the "hashes"
%   between function calls from one job to the next allows GAB to determine
%   if anything has changed at the top level. 
%
%   As originally written by Hill, this will only work on a unix based
%   system with access to the MD5SUM function call. Bishop modified this
%   function to work within Windows using the FCIV function. See
%   http://support.microsoft.com/kb/889768 for details. Should be able to
%   modify this to work with Macs as well, but the need hasn't arised yet.
%   
% INPUT:
%
%   task:   GAB task structure - flexible.
%
% OUTPUT:
%
%   task:   original input task with an additional field 'funcHashes' with
%           subfields
%               funcName:   Function name
%               md5:        MD5 Hashes
%
% Hill, Kevin T.
%   Modifications by C. Bishop. 2013

func_list=depfun(which(func2str(task.func)),'-toponly','-quiet');

task.funcHashes=struct('funcName',[],'md5',[]);

for f=1:length(func_list)
    
    % Gather file parts
    [~,file]=fileparts(func_list{f});
    
    task.funcHashes(f).funcName=file;
    
    % UNIX
    if isunix()
        [err,outp]=unix(['md5sum ' func_list{f}]);
        if err
            error(['Tried to get hash for unknown function: ' func_list{f}]);
        end
        task.funcHashes(f).md5=outp(1:32); %the hash is the first 32 characters of the output
    elseif ispc()
        command=['FCIV -md5 ' func_list{f}];
        [~, outp]=dos(command);
        
        % Grab MD5 Hash
        task.funcHashes(f).md5=outp(find(outp=='/', 1, 'last') +2: find(outp=='/', 1, 'last') +2 +31);
    else
        error('Unknown operating system');
    end % if isunix/ispc
    
end