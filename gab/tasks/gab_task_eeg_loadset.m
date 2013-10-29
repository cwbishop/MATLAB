function results=gab_task_eeg_loadset(args)
%a wrapper function for pop_loadset from eeglab that can load multiple eeg
%datasets into separate cells.

%main output, make it global
global EEG
EEG = eeg_emptyset; %note, this only works if you have my version of eeg_emptyset, which actually gives you a complete empty set, not just half of one....

if ~iscell(args.file)
    args.file={args.file};
end
if ~iscell(args.path)
    args.path={args.path};
end

if length(args.path)==1
    for s=1:length(args.file) % do for each eeg session
        EEG(s) = pop_loadset('filename',args.file{s},'filepath',args.path{1});
    end

else
    for s=1:length(args.file) % do for each eeg session
        EEG(s) = pop_loadset('filename',args.file{s},'filepath',args.path{s});
    end
end
results='done';