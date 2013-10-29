function results=gab_task_eeg_load(args)
%a wrapper function for pop_loadset from eeglab that can load multiple eeg
%datasets into separate cells.

%main output, make it global
global EEG

if ~iscell(args.file)
    args.file={args.file};
end

for s=1:length(args.file) % do for each eeg session
    EEG(s) = pop_loadset(args.file{s});
end

results='done';