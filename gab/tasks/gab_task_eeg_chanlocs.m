function results=gab_task_eeg_chanlocs(args)
%loads a channel location file into eeglab batching scripts

global EEG

if ischar(args.file)
    args.file={args.file};
end

if length(args.file)==1;
    args.file=repmat(args.file,length(EEG),1);
end

if length(args.file) ~= length(EEG)
    error('You must specify a channel location file for each EEG structure, or a single file for all structs');
end

for s=1:length(EEG)
%     locs = readlocs(args.file{s}); 
    EEG(s) = pop_chanedit(EEG, 'lookup', args.file{s}); 
    
end % s=1:length(EEG)

results = 'done';