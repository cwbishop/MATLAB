function results=gab_task_eeg_mergeset(args)
%wrapper function for pop_mergeset from eeglab. 

%EEG should already be loaded
global EEG

EEG = pop_mergeset(EEG,1:length(EEG));
    
results='done';