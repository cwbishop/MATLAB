function results = gab_task_eeg_filter(args)
% DESCRIPTION:
%
%   Wrapper function to pop_eegfilt for use with GAB.  Please be aware that
%   some filtering functions may not operate properly for bandpass filters
%   (see warning from pop_eegfilt.m).  To CB's knowledge, this only occurs
%   when eegfilt (using filtfilt) is called.  
%
%   As KT pointed out during discussion, the clipped FFt method employed by
%   EEGLAB isn't the best solution.  For instance, it will introduce large 
%   transients (i.e. something looking like a delta function) into a
%   propogating sine wave not present in the data.
%
%   As an alternative (CB's recommendation), you can used FDATOOL to design
%   a custom filter and export, check its frequency response, then export 
%   it to a MAT-File.  Then, call gab_task_eeg_CustomFilter.m to apply this 
%   custom filter to your data.  The takehome message is, do NOT trust
%   EEGLAB's filtering.  Check your frequency responses!
%
% INPUT:
%   
%   args        structure, input arguments with the following fields:
%       .order: double, filter order. Length of filter in SAMPLES (duration
%               will depend entirely on your sampling rate (EEG.srate)).
%               *Note*: Order doesn't do anything unless .type is set to
%               'filtfilt'.
%       .low:   double, low pass frequency cutoff.
%       .high:  double, high pass frequency cutoff.
%       .type:  string, type of filter. Options are 'filtfilt' or
%               'fftfilt' (default).
%
% OUTPUT:
%
%   results
%
% Hill, KT 2010
%   Modifications by Bishop CW 2010

global EEG

if ~isfield(args, 'type') || isempty(args.type)
    args.type = 'fftfilt';
end

for s=1:length(EEG)
    if ~isfield(args, 'order')
        args.order = round(3*EEG(s).srate/args.low); %use the eeglab default if not specified.
    end
    
    % Users specify which filter type they want to use.  If they don't
    % specify, then use fftfilt by default because of known issues with
    % bandpass FIRLS filters.
    if strcmp(args.type, 'filtfilt')
        EEG(s)=pop_eegfilt(EEG(s),args.low,args.high,args.order,0,0);
    elseif strcmp(args.type, 'fftfilt')
        EEG(s)=pop_eegfilt(EEG(s),args.low,args.high,args.order,0,1); %use eeglab's fft filt, which works better
    elseif strcmp(args.type, 'custom')
        gab_task_eeg_CustomFilter(args);
    else 
        error('Please specify an appropriate filter type.');
    end % if 
end

results = 'done';