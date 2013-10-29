function results=gab_task_eeg_mean_center_chans(args)
%biosemi does some odd things with channel baselines. If you are working
%with continuous data, mean centering can be more friendly. Seems to me
%that this should be done

global EEG

for s=1:length(EEG)
    
    EEG{s}.data=EEG{s}.data-repmat(mean(EEG{s}.data,2),1,size(EEG{s}.data,2));
    
end

results='done';