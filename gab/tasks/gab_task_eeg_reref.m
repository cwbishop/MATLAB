function results=gab_task_eeg_reref(args)
%wrapper function for pop_reref from eeglab, used to rereference data in
%the EEG structure format.

%EEG should already be loaded
global EEG

for s=1:length(EEG) % do for each eeg session
    %EEG{s} = pop_reref(EEG{s},args.ref,'method','withref'); %old, simple
    %way to do this, but it was buggy for some reason
    
    display('Re-referencing...');
    EEG{s}.data=EEG{s}.data-repmat(mean(EEG{s}.data(args.ref,:),1),size(EEG{s}.data,1),1);
    EEG{s}.ref='common'; %this line should be improved, as it might not always be common ref
end

results='done';