function results = gab_task_mkdir(DNAMES)
%% DESCRIPTION:
%
%   GAB friendly function to create directories. Can be used to create
%   study or subject-specific file trees. Has only been
%   extensively tested on Windows 7 OS, however, so it might need some
%   attention for other operating systems.
%
% INPUT:
%
%   DNAMES: Cell array, each element is a full path to the directory you'd
%           like made.
%
% OUTPUT:
%
%   results:    hold over from GAB setup - not used for anything, really.
%
% Christopher Bishop
%   University of Washington 
%   12/13

for i=1:length(DNAMES)
    eval(['! mkdir ' DNAMES{i}]);    
end % for i=1: ...

% Hold over for GAB. No known function.
results = 'done';