function CNT_CHANOPS(IN, OUT, CHANOPS, OCHLAB, BLOCKSIZE)
%% DESCRIPTION:
%
%   Function to perform channel operations (e.g., referencing) of Neuroscan
%   CNT files. This has been useful when dealing with large (>5 GB) CNT
%   files that cannot always be loaded into a standard desktop computer.
%   EEGLAB v12.0.2.5b has memory mapping functionality with CNT files that
%   dramatically reduce the memory requirements, but it slows computation
%   time (particularly epoching functions) to a crawl. With a single
%   channel of data sampled at 20 kHz that can be epoched in ~3-5 mins
%   without memory mapping, it takes 30 - 90 minutes with memory mapping
%   enabled. Thus it became necessary to potentially rewrite data with only
%   select channels or to perform referencing in a multiplexed CNT format.
%
%   This requires a modified version of EEGLAB's 'loadcnt' as well as
%   'writecnt'. Please see their respective help files. 
%
% INPUT:
%
%   IN:  string, path to original BDF.
%   OUT: string, path to trimmed BDF.
%   CHANOPS:    cell array, each element contains a mathematical evaluation
%               string (e.g. '(A1 + A2)./2' to average channels A1 and A2).
%               Note that channel names in CHANOPS must match the channel
%               names in the BDF precisely.
%
%               *Note*: Function assumes all channels included in a given
%               operation -- that is, an element of the cell array -- are
%               of the same transducer type and sampling rate. A safe 
%               assumption for EEG, but could be a problem for other
%               applications.
%   OCHLAB: cell array, output channel names. Must be the same length as
%           CHANOPS. (optional input)
%   BLOCKSIZE:  integer, number of seconds of continuous data to read in
%               simultaneously (default=1); To load the whole dataset
%               (useful for testing on small data sets) set to -1.
%
% OUTPUT:
%
%   nothing useful that I can think of ...
%
% Christopher W. Bishop
%   1/14
%   University of Washington

%% INPUT CHECK
if ~exist('BLOCKSIZE', 'var') || isempty(BLOCKSIZE), BLOCKSIZE=1; end 

%% GET EVENT TABLE
%   use same call used to read data segment below
if BLOCKSIZE>0 && BLOCKSIZE<1
    ostruct=CNT_READ(IN, [0 BLOCKSIZE]); 
else
    ostruct=CNT_READ(IN, [0 1]); 
end % if 



%% INITIATE NECESSARY VARIABLES
CHLAB=cell(length(ostruct.electloc),1); % CHannel LABels


% Number of total samples in the CNT file
nsamps=ostruct.header.numsamples;   % total number of recorded samples
srate=ostruct.header.rate;         % rate of recording

%% DOUBLE CHECK BLOCK SIZE
if BLOCKSIZE==-1
    BLOCKSIZE=ceil(nsamps./(srate));
end % if BLOCKSIZE==-1

%% GRAB CHANNEL LABELS
%   Need these later to figure out operation information.
for i=1:length(ostruct.electloc)
    CHLAB{i}=ostruct.electloc(i).lab;
end % i=1:length(ostruct.electloc)

%% LOOP THROUGH DATA
for i=1:ceil(nsamps./(BLOCKSIZE*srate))
    
    %% READ DATA SEGMENT
    tstruct=CNT_READ(IN, [(i-1)*BLOCKSIZE i*BLOCKSIZE]); 
    data=tstruct.data; 
    
    %% PERFORM CHANNEL OPERATION
    for c=1:length(CHANOPS)
        odata(c,:)=EVAL_CHANOPS(data, CHLAB, CHANOPS{c}); 
    end % c=1:length(CHANOPS)
    
    %% REARRANGE CNT DATASET INFORMATION FOR WRITING
    %   call EDIT_CNTSTRUCT
    OSTRUCT=EDIT_CNTSTRUCT(tstruct, OCHLAB, odata); 
    
    %% WRITE DATA SEGMENT
    %   Edit writecnt to allow appending of data, writing just the event
    %   table, and writing everything at once. This will be a bear, but
    %   made easier by the fact that we have something to start with. 
    writecnt(OUT, OSTRUCT, 'dataformat', OSTRUCT.dataformat);
    
end % for i=1:ceil(nsamps./ ...)
end % CNT_CHANOPS

function CNT=CNT_READ(IN, T)
%% DESCRIPTION:
%
%   Function to read a given CNT data segment (defined by time inputs). 

%% INPUT CHECK
if length(T)==1, T=[T T]; end % need 2 elements

CNT=loadcnt(IN, 't1', T(1), 'lddur', diff(T)); 
end % CNT_READ

function OCNT=EDIT_CNTSTRUCT(CNT, OCHLAB, DATA) 
%% DESCRIPTION:
%
%   Function to change CNT structure so it plays nicely with writecnt.m.
%
% INPUT:
%
%
% OUTPUT:
%
%   
%
% Christopher W. Bishop
%   University of Washington 
%   1/14

%% COPY OVER ALL CNT INFO
OCNT=CNT; 

%% PUT IN DATA
OCNT.data=DATA;

%% LABEL INFORMATION

% Rename channel labels
for c=1:size(DATA,1)
    OCNT.electloc(c).lab=OCHLAB{c};
    OCNT.electloc(c).reference=-1; % nonsense value so I don't forget this is a custom reference.
end % c=1:size(DATA,1)

% Discard channels we won't use
OCNT.electloc=OCNT.electloc(1:size(DATA,1)); 

%% MODIFY HEADER

%% FIELDS THAT NEED CHANGING
%   electrode information is 75 bytes each. Confirmed in loadcnt.m
%
% CWB: need to add functionality for 16 bit CNTs (2 bytes instead of 4)
OCNT.header.nextfile=OCNT.header.nextfile - (numel(CNT.data) - numel(OCNT.data)).*4 - (length(CNT.electloc) - length(OCNT.electloc)).*75; % subtract data size AND electrode information
OCNT.header.nchannels=size(DATA,1);  % definitely needs to change
OCNT.header.eventtablepos=OCNT.header.eventtablepos - (numel(CNT.data) - numel(OCNT.data)).*4 - (length(CNT.electloc) - length(OCNT.electloc)).*75; % subtract data size AND electrode information
end % EDIT_CNTHEADER

function [ODATA]=EVAL_CHANOPS(DATA, CHLAB, OP)
%% DESCRIPTION:
%
%   Function to interpret and evaluate specified channel operation strings.
%   Notice that these data are first converted from their BDF format to a
%   microVolt signal according similar to BIOSIG.  The mathematical
%   operations are then performed on these transformed data and the data
%   are then transferred BACK into BDF format.  
%
% INPUT:
%
%   DATA:   CxT matrix, where C is the number of channels and T is the
%           number of timepoints
%   CHLAB:  Cell array, each element is the channel label corresponding to
%           the corresponding row of DATA. For instance, CHLAB{1}='FP1'
%           associates the data in the first row of DATA with channel FP1.
%           Care should be taken to properly label since improper labeling
%           will lead to incorrect channel operations.
%
% OUTPUT:
%
%   ODATA:  Transformed BDF data.
%
% Christopher W Bishop
%   University of Washington
%   1/14
%   cwbishop@uw.edu

% First, assign DATA to variables. Variables will be named after the
% channel labels
for c=1:length(CHLAB)
    eval([CHLAB{c} '=[];']); 
    eval([CHLAB{c} '=DATA(c,:);']);    
end % c=1:length(HDR.CHLAB)

% Evaluate channel operation
eval('ODATA=eval(OP);'); 

end % EVAL_CHANOPS