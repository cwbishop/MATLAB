function results=gab_task_eeg_interp(args)
%function gab_task_eeg_interp(args)
%
%Performs a linear interpolation using the nearest 3 neighbors. 3d
%channel location info must be already loaded. If there are more than 3
%channels the same distance away, they will also be included in the
%interpolation
%
%args.badchans = the bad channels to be interpolated. This can either be a
%cell array of channel labels as in {'A01','C23'} or the number of the
%channel in a numberical array as in [ 1 27 49]
%
%EEG.interplabels and EEG.interpnums are added to the EEG structure to keep
%track of labels and numbers of the channels which were interpolated

if isfield(args,'badchans') && ~isempty(args.badchans)

    global EEG;

    if ~isfield(args,'minNeighbors') || isempty(args.minNeighbors)
        minNeighbors=3;
    else
        minNeighbors=args.minNeighbors;
    end

    badchans=args.badchans;

    if iscell(badchans)
        badnums = find(ismember({EEG.chanlocs.labels},badchans)); %get the channel numbers of the bad channels
        [tmp goodnums] = setdiff({EEG.chanlocs.labels},badchans); %get the channel numbers of the good channels
        goodnums = sort(goodnums);
    else
        badnums = badchans;
        goodnums = setdiff(1:length(EEG.chanlocs),badchans);
        goodnums = sort(goodnums);
    end

    EEG.chaninfo.interpchans = {EEG.chanlocs(badnums).labels};

    %make sure we have a safe reference
    if ischar(EEG.ref) || ismember(badnums,EEG.ref)
        EEG.data=EEG.data-repmat(mean(EEG.data(goodnums,:),1),size(EEG.data,1),1);
        newref=true;
    else
        newref=false;
    end

    goodspace = [EEG.chanlocs(goodnums).X; EEG.chanlocs(goodnums).Y; EEG.chanlocs(goodnums).Z]'; %%the 3d coordinates of the good channels

    for b = badnums
        badspace = repmat([EEG.chanlocs(b).X; EEG.chanlocs(b).Y; EEG.chanlocs(b).Z]',length(goodnums),1); % the 3d coordinates of a bad channel, repeated to fit the good channels
        difspace = badspace-goodspace;
        d = sqrt(sum(difspace.^2,2)); %the distance between the bad channel and each good channel
        [d i]= sort(d);

        %take only those points that are at least as close as minNeigbhor'th closest point
%         i=i(dist<=dist(minNeighbors));
        i=goodnums(i(d<=d(minNeighbors)));
        D=[];
        for z=1:length(i)
            D(z)=d(find(goodnums==i(z)));
        end % z
        d=D;
        clear D;
        %weight each point by it's relative distance
        norm=sum(d);
        w=d./norm;

        %build channel's data as weighted sum of nearest good channels
        EEG.data(b,:)=EEG.data(i,:)'*w';

        %record which channels are interped
        EEG.chaninfo.interpchans=[EEG.chaninfo.interpchans b];
    end

    if newref
        if ischar(EEG.ref); %if we have an 'averef' stored in EEG.ref
            EEG.data=EEG.data-repmat(mean(EEG.data,1),size(EEG.data,1),1);
        else
            EEG.data=EEG.data-repmat(mean(EEG.data(EEG.ref,:),1),size(EEG.data,1),1);
        end
    end
end

results='done';
