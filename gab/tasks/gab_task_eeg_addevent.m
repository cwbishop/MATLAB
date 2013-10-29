function results=gab_task_eeg_addevent(args)
%home grown function to add in event(s) time locked to another event(s) in
%an eeglab structure. Based on code from JK

%EEG should already be loaded
global EEG

for s=1:length(EEG)
    if ~isempty(EEG(s).epoch)
        error('EEG data structure already epoched. Add events before epocing')
    end
    for e=1:length(EEG(s).event)
        if isnumeric(EEG(s).event(e).type) %it seems inconsistent if event type is kept as numeric or a string, just change everything it string for simplicity
            EEG(s).event(e).type=num2str(EEG(s).event(e).type);
        end
        if strmatch(EEG(s).event(e).type, args.ref,'exact') %allow matching to multiple reference events
            %debug line
            %fprintf(1,'Event number %d: Found event type %s with latency %d. Creating new event with latency %d\n',e,args(c).ref,EEG(s).event(e).latency,[EEG(s).event(e).latency + (args(c).offset * EEG(s).srate)]);
            for o=1:length(args.offset) %can have multiple offsets (but only one type and duration) per add.
                EEG(s).event(end+1)=struct(...
                    'type',args.type,...
                    'latency',[EEG(s).event(e).latency + (args.offset(o) * EEG(s).srate)],...
                    'duration',max([args.duration * EEG(s).srate],1),...
                    'urevent',[]);
            end
        end
    end

    %resort the events based on latency. not required, but helpful.
    [Y,ievent]=sort([EEG(s).event.latency]);
    EEG(s).event=EEG(s).event(ievent);
    
    EEG(s) = eeg_checkset(EEG(s), 'makeur'); %need to update EEG.urevent
end

results='done';