function results=gab_task_eeg_loadbdf(args)
%a wrapper function for pop_loadset from eeglab that can load multiple eeg
%datasets into separate cells.

%main output, make it global
global EEG
EEG = eeg_emptyset; %note, this only works if you have my version of eeg_emptyset, which actually gives you a complete empty set, not just half of one....

if ~iscell(args.file)
    args.file={args.file};
end
if ~isfield(args,'ref')
    args.ref=1; %unreferenced biosemi files loose 40dB snr if they remain unreferenced. You can always reref later
end
if ~isfield(args,'chans')
    args.chans=[]; %by default, just grab all available channels
end
if ~isfield(args,'rmeventchan')
    args.rmeventchan='off'; %eeglab is messed up, if you tell it to only select a set number of channels, you also have to tell it NOT to remove the status channel. Buggy bug bug
end

for s=1:length(args.file) % do for each eeg session
    EEG(s) = pop_biosig(args.file{s},'channels',args.chans,'ref',args.ref,'rmeventchan',args.rmeventchan);
end

results='done';