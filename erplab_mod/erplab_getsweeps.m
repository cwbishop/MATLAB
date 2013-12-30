function [DATA, IND]=erplab_getsweeps(EEG, BINS, ARTCRITE)
%% DESCRIPTION:
%
%   Function to extract bin labeled sweeps from EEG structure. This proved
%   useful when doing offline, custom analyses that required individual
%   sweep data (e.g., trial-to-trial power spectra).
%
%   Currently checks BINS agains EEG.event(:).bini. It's important that the
%   user overwrite the event structure through ERPLAB (see 
%
%   Code is based largely off of MSPE_ERPLAB_getbindata.m
%
%   Tested with ERPLAB version 4.0.2.3.
%
% INPUT:
%
% INPUT:
%
%   EEG:    EEG structure.
%   BINS:   double array, bin index from BINLISTER file. 
%   ARTCRITE:   integer, flag describing how rejected trials should (or
%               should not) be included.
%               
%               From pop_averager.m:
%               %  artcrite = 0 --> averaging all (good and bad trials)
%               %  artcrite = 1 --> averaging only good trials
%               %  artcrite = 2 --> averaging only bad trials
%
% OUTPUT:
%
%   DATA:   CxTxN data matrix, where C=the number of channels, T=the number
%           of time points and N is the number of sweeps. Note that to
%           match ERPLAB output PRECISELY, use the following command to
%           compute the ERP
%
%               double(sum(DATA,3))./length(IND);
%
%   IND:    index of included epochs
%
% Bishop, Christopher W.
%   University of Washington
%   12/2013
%   cwbishop@uw.edu

%% DEFAULTS
%   No defaults set - the user must explicitly define what he/she wants.

%% EXTRACT SWEEPS BASED ON BIN LABEL
%   I stole some code from ERPLAB to figure out which trials are rejected.
% averager.m (84-95)
F = fieldnames(EEG.reject); % Gather fieldnames in rejection field
sfields1 = regexpi(F, '\w*E$', 'match'); %
sfields2 = [sfields1{:}];
fields4reject  = regexprep(sfields2,'E',''); % Rejection fields

% Initialize data like ERPLAB does ...
binsum=zeros(size(EEG.data,1), size(EEG.data,2));

IND=[];

for i=1:length(EEG.epoch)
    bini=EEG.epoch(i).eventbini{1}; % stored as cell, so make it double array
    bepoch=i;
    % Flag set to 1 if included, set to 0 if rejected.
    %   Recall that rejection information is stored based on EPOCH
    %   information, not on individual eventinfo.
%     bepoch=EEG.EVENTLIST.eventinfo(i).bepoch;
%     bepoch=EEG.event(i).epoch; % epoch is just 
    try
        flag = eegartifacts(EEG.reject, fields4reject, bepoch);
    catch
        flag=0; % toss trial if we can't be sure it's OK.
    end; 
    
    % If this is a rejected trial, but user wants to include good and bad
    % trials.
    if ARTCRITE==0
        flag=1; 
    end % 
    
    % If user wants ONLY bad trials
    if ARTCRITE==2
        if flag==1 % if it's an otherwise good trial.
            flag=0; % toss the good trials.
        elseif flag==0 % if it's a bad trial
            flag=1; % then include the bad trials.
        end % if flag==1, etc. 
    end % ARTCRITE==2    
    
    % If the user wants to include this bin and this particular sweep, then
    % add this sweep to the index. 
    if ~isempty(find(ismember(bini, BINS),1)) && flag
        IND(end+1)=bepoch;
        
        % Tracking binsum
        %   used for debugging
        binsum(:,:,1)=binsum(:,:,1)+EEG.data(:,:,i);
    end % if 
end % i

DATA=EEG.data(:,:,IND); 