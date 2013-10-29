function results=gab_task_eeg_resample(args)
%wrapper function for pop_resample from eeglab, used primarily to
%downsample eeg recordings, but could be used for upsampling if that were
%required

%EEG should already be loaded
global EEG

for s=1:length(EEG) % do for each eeg session
    
    EEG(s) = pop_resample(EEG(s),args.freq);
end

results='done';