function results=gab_task_load(args)
%basic gab task for loading a file or many files and making them globals
%for use in other tasks.
%
%Input
% args - should contain on or two fields:
%  .mats  - a cell array of strings with the full file to be loaded
%  .globs - (optional) a cell array of cell arrays of stings, which lists
%           the variables which should be made global for each loaded file.
%           If this variable doesn't exist, or is empty, all variables in
%           the .mat files will be made global.

mats=args.mats;
if isfield(args,'globs')
    globs=args.globs;
else
    globs=cell(size(mats));
end

for f=1:length(mats) % walk though .mat files
    vars=load(mats{f});
    if isempty(globs{f}) %if we don't list any specific vars to make global, assume we want everything
        globs{f}=fieldnames(vars);
    end
    for v=1:length(globs{f})
        try
            eval(['global ' globs{f}{v}]) %create global first to avoid warning, and maintain forward compatibility.
            eval([globs{f}{v} ' =  vars.(globs{f}{v});'])
        catch
            warning(['Unable to load ' globs{f}{v} ' from ' mats{f}]) %maybe this should just let it error....
        end
    end
end

results='done';