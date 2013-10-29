function results=gab_task_eeg_CustomFilter(args)
% DESCRIPTION:
%
%   Filter EEG dataset with a custom filter.  Typically, the filter is
%   designed using a GUI (e.g. FDATOOL), its frequency response verified
%   (very important), then the coefficients are exported to a .MAT file.
%   The mat file must contain all information relevant to the filter.
%
% INPUT:
%   
%   args
%       .mat:   string, full path to stored MAT-FILE
%
% OUTPUT:
%
%   results:    string, results per GAB conventions. 
%
% Bishop, Chris 2010

global EEG;
% load custom filter
load(args.mat);

% b is the numerator
if exist('Num', 'var')
    b=Num;
end 

if exist('Den', 'var')
    a=Den;
end

% If there isn't a denominator, assume it's 1.
if ~exist('a', 'var')
    a=1;
end % 

%% FILTER USING FILTFILT
%   Two things are important to remember here. First, the signal is
%   filtered TWICE. This has two effects: 1) All phase shifts are undone
%   (zero-phase filter) and 2) the magnitude filtering is done TWICE...so,
%   a 50 dB drop in your filter will actually be 100 dB in your (filtered)
%   signal.
for i=1:size(EEG.data)
    OUT(i,:)=filtfilt(b,a,EEG.data(i,:));
    
    % Display like EEGFILT
    if ~mod(i,20)
        fprintf(num2str(i));
    else
        fprintf('.');
    end % if 
    
end % i

%% ASSIGN FILTERED DATA
EEG.data=OUT;
results='done';