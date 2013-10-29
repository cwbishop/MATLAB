function results=gab_task_eeg_badchannel(args)
%a function that will remove channels that are obviously bad and replace
%them with interpolated data. Current critera is 10 times the median channel
%rms.
%
%This should only be done after mergeing eeg sets (could be changed without
%too much trouble to accept multiple eeg sets)

%EEG should already be loaded
global EEG

if ~isfield(args,'banchans')
    args.badchans=[];
end
if ~isfield(args,'thresh') || isempty(args.thresh)
    args.thresh=10;
end
if ~isfield(args,'minNeighbors') || isempty(args.minNeighbors)
    args.minNeighbors=3;
end

if args.thresh
    p=rms(EEG.data');

    %make sure we don't get two copies of a channel
    args.badchans=unique([args.badchans find(p>10*median(p))]);
    args.minNeighbors=3;
end

% if ~isempty(args.badchans)
    gab_task_eeg_interp(args);
% end

results='done';