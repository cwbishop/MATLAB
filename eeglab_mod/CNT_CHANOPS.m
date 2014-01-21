function CNT_CHANOPS(IN, OUT, CHANOPS, OCHLAB, BLOCKSIZE, DATAFORMAT)
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
%   DATAFORMAT: 'int16' | 'int32'; If empty, the native precision of the
%               input file is used.
%
% OUTPUT:
%
%   nothing useful that I can think of ...
%
%       Successful runs :
%       IN=fullfile('C:\Users\cwbishop\Downloads', 'projq_G4_257_6day4.cnt'); OUT=fullfile('C:\Users\cwbishop\Downloads', 'TEST.cnt');CHANOPS={'FP1'}; OCHLAB={'FP1'}; BLOCKSIZE=878120./50./1000;
%       IN=fullfile('C:\Users\cwbishop\Downloads', 'projq_G4_257_6day4.cnt'); OUT=fullfile('C:\Users\cwbishop\Downloads', 'TEST.cnt');CHANOPS={'FP1'}; OCHLAB={'FP1'}; BLOCKSIZE=-1;
%       IN=fullfile('C:\Users\cwbishop\Downloads', 'projq_G4_257_6day4.cnt'); OUT=fullfile('C:\Users\cwbishop\Downloads', 'TEST.cnt');CHANOPS={'FP1'}; OCHLAB={'FP1'}; BLOCKSIZE=1;
%       
%
% Tested with the following inputs:
% Christopher W. Bishop
%   1/14
%   University of Washington

%% INPUT CHECK
if ~exist('BLOCKSIZE', 'var') || isempty(BLOCKSIZE), BLOCKSIZE=1; end 
if ~exist('DATAFORMAT', 'var'), DATAFORMAT=[]; end % use default data format

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
%   if the block size is set to -1, then load in the whole file. 
if BLOCKSIZE==-1
    BLOCKSIZE=ceil(nsamps./(srate));
end % if BLOCKSIZE==-1

%% GRAB CHANNEL LABELS
%   Need these later to figure out operation information.
for i=1:length(ostruct.electloc)
    CHLAB{i}=ostruct.electloc(i).lab;
end % i=1:length(ostruct.electloc)

%% LOOP THROUGH DATA
BLOCKSIZE=round(BLOCKSIZE*srate); % convert to samples
nblocks=ceil(nsamps./(BLOCKSIZE));

% IND
IND=[];
for i=1:nblocks
    disp(['Writing block: ' num2str(i) '/' num2str(nblocks)]); 
    %% READ DATA SEGMENT
    if i==1
        ind = [(i-1)*BLOCKSIZE i*BLOCKSIZE-1];
    elseif i==nblocks
        ind = [(i-1)*BLOCKSIZE nsamps-1];
    else
        ind = [(i-1)*BLOCKSIZE i*BLOCKSIZE-1];
    end %
    IND=[IND; ind]; % for debugging purposes. 
    tstruct=CNT_READ(IN, ind); 
    data=tstruct.data; 
    
    %% PERFORM CHANNEL OPERATION
    %   Preallocate odata size for speed. 
    odata=nan(length(CHANOPS), size(data,2)); 
    for c=1:length(CHANOPS)
        odata(c,:)=EVAL_CHANOPS(data, CHLAB, CHANOPS{c}); 
    end % c=1:length(CHANOPS)
    
    %% REARRANGE CNT DATASET INFORMATION FOR WRITING
    %   call EDIT_CNTSTRUCT   
    
    %% WRITE INFORMATION TO FILE    
    if i==1
        % Write header, electrode, data segment
        %   Double check that header information reflects all data that
        %   will eventually be written to file, not just this segment.
        %
        %   OSTRCUT varies depending on what the user is writing - the
        %   header must reflect the final file size (samples, channels,
        %   etc.), but an individual data segment must reflect the
        %   information needed to write a short segment of data. Thus, the
        %   clunky, sequential calls.
        
        % Write Header        
        WRITE_HEADER(OUT, tstruct, OCHLAB, odata, DATAFORMAT);      
        
    end % write header
    
    % Always write the data segment
    WRITE_DATASEG(OUT, tstruct, OCHLAB, odata, DATAFORMAT); 
    
    % Write event table and endtag
    if i==nblocks
        % Write event table and endtag
        %   Use ostruct because we want event table onsets to load
        %   correctly. 
        WRITE_EVENTTAG(OUT, ostruct, OCHLAB, odata, DATAFORMAT); 
    end % if i==nblocks           
        
end % for i=1:nblocks
end % CNT_CHANOPS

function WRITE_HEADER(OUT, CNT, OCHLAB, DATA, DATAFORMAT)
%% DESCRIPTION:
%
%   Function to write header information to CNT file. Proved to be helpful
%   to modularize this. I was copying and pasting code all over the place!
%   A good sign I needed a separate function ;). 
%
% INPUT:
%
%   OUT:    string, full path to output file.
%   CNT:    CNT dataset structure, returned from loadcnt.m.
%   OCHLAB: cell array, output channel names
%   DATA:   CxT matrix, where C is the number of channels and T the number
%           of samples per channel.
%   DATAFORMAT: string ('header' | 'data') used for massaging the header
%           information into something useful for writecnt.m. Use 'header'
%           here.
%
% OUTPUT:
%
%   Header written to file.   
%
% Christopher W. Bishop
%   University of Washington
%   1/14
%   cwbishop@uw.edu

%% GET AN APPROPRIATE CNT DATA STRUCTURE
OSTRUCT=EDIT_CNTSTRUCT(CNT, OCHLAB, DATA, DATAFORMAT,'header'); 
writecnt(OUT,OSTRUCT,'dataformat',OSTRUCT.dataformat,...
            'header', true, ...
            'electrodes', true, ...
            'data', false, ...
            'eventtable', false, ...
            'endtag', false, ...
            'append', false);

end % WRITE_CNTHEADER

function WRITE_DATASEG(OUT, CNT, OCHLAB, DATA, DATAFORMAT)
%% DESCRIPTION:
%
%   Function to write a segment of data to CNT file. Data are appended to a
%   file that is assumed to exist. 
%
% INPUT:
%
%   See WRITE_HEADER. Set DATAFORMAT='data';
%
% OUTPUT:
%
%   Data segment written to file
%
% Christopher W. Bishop
%   University of Washington
%   1/14
%   cwbishop@uw.edu

OSTRUCT=EDIT_CNTSTRUCT(CNT, OCHLAB, DATA, DATAFORMAT,'data'); 

writecnt(OUT,OSTRUCT,'dataformat',OSTRUCT.dataformat,...
            'header', false, ...
            'electrodes', false, ...
            'data', true, ...
            'eventtable', false, ...
            'endtag', false, ...
            'append', true);
        
end % function WRITE_DATASEG

function WRITE_EVENTTAG(OUT, CNT, OCHLAB, DATA, DATAFORMAT)
%% DESCRIPTION:
%
%   Write event table and event tag to file. This information is appended
%   to a file assumed to exist already.
%
% INPUT:
%
%   See WRITE_HEADER. Use DATAFORMAT='header' here.
%
% OUTPUT:
%
%   Event Table and End Tag written to file.
%
% Christopher W. Bishop
%   University of Washington
%   1/14
%   cwbishop@uw.edu

OSTRUCT=EDIT_CNTSTRUCT(CNT, OCHLAB, DATA, DATAFORMAT,'header');

 % Write last data segment, eventtable, and endtag
writecnt(OUT,OSTRUCT,'dataformat',OSTRUCT.dataformat,...
    'header', false, ...
    'electrodes', false, ...
    'data', false, ...
    'eventtable', true, ...
    'endtag', true, ...
    'append', true);

end % WRITE_EVENTTAG

function CNT=CNT_READ(IN, T)
%% DESCRIPTION:
%
%   Function to read a given CNT data segment (defined by samples). 
%
% INPUT:
%
%   IN: string, full path to input file.
%   T:  2 element array, beginning and end samples to load. 
%
% OUTPUT:
%
%   CNT:    CNT dataset returned from loadcnt.
%
% Christopher W. Bishop
%   University of Washington
%   1/14

%% INPUT CHECK
if length(T)==1, T=[T T]; end % need 2 elements

CNT=loadcnt(IN, 'sample1', T(1), 'ldnsamples', diff(T)+1); % add one for T(1);
end % CNT_READ

function OCNT=EDIT_CNTSTRUCT(CNT, OCHLAB, DATA, DATAFORMAT, WTYPE) 
%% DESCRIPTION:
%
%   Function to change CNT structure so it plays nicely with writecnt.m.
%   Currently, the function will essentially overwrite or edit existing
%   channels, so electrode locations and other metadata should be largely
%   ignored. This editing is designed mainly to get the datapoints in and
%   out of a CNT file format quickly. 
%
% INPUT:
%
%   CNT:    CNT data structure, as returned from loadcnt.m and used by
%           writecnt.m. See those functions for details.
%   OCHLAB: cell array, each element is a string defining the name of the
%           output channel
%   DATA:   CxT matrix, where C is length(OCHLAB) and T is the number of
%           time points.
%   DATAFORMAT: 'int16' | 'int32'. Default = CNT.dataformat. 
%
% OUTPUT:
%
%   OCNT:   Edited CNT data structure for the output channels and data.
%           This structure can be passed to writecnt.m and the data written
%           to file.
%
% Christopher W. Bishop
%   University of Washington 
%   1/14

%% DEFAULT DATA PRECISION
if ~exist('DATAFORMAT', 'var') || isempty(DATAFORMAT), DATAFORMAT=CNT.dataformat; end 
if ~exist('WTYPE', 'var'), WTYPE=[]; end % 

%% COPY OVER ALL CNT INFO
OCNT=CNT; 

%% ESTABLISH DATA FORMAT
OCNT.dataformat=DATAFORMAT; 

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

%% FIELDS THAT NEED CHANGING
%   electrode information is 75 bytes each. Confirmed in loadcnt.m
%
% CWB: need to add functionality for 16 bit CNTs (2 bytes instead of 4)
if strcmp(OCNT.dataformat, 'int32')
    bytes=4;
elseif strcmp(OCNT.dataformat, 'int16')    
    bytes=2;
else
    error('CNT_CHANOPS:UnknownDataPrecision', 'Could not determine data precision'); 
end % strcmp(OCNT.dataformat ...

% Number of bytes removed from data
if strcmpi(WTYPE,'header')
    rmbytes=(CNT.header.numsamples*CNT.header.nchannels - CNT.header.numsamples*length(OCHLAB)).*bytes + (length(CNT.electloc) - length(OCNT.electloc)).*75;
elseif strcmpi(WTYPE,'data')
    % Subtract data written in other channels, remove electrode headers,
    % remove all but the number of samples to write
    rmbytes=(CNT.header.numsamples*CNT.header.nchannels - numel(OCNT.data)).*bytes + (length(CNT.electloc) - length(OCNT.electloc)).*75;
%     rmbytes=(numel(CNT.data) - numel(OCNT.data)).*bytes + (length(CNT.electloc) - length(OCNT.electloc)).*75; % subtract data size AND electrode information
else
    error('Data type not specified'); 
end % if strcmp

% Adjust several header parameters to reflect truncated data (removed
% channels).
OCNT.header.nextfile=OCNT.header.nextfile - rmbytes;
OCNT.header.eventtablepos=OCNT.header.eventtablepos - rmbytes;
OCNT.header.nchannels=length(OCHLAB);

% Previous header adjustments tested with full files read in
% OCNT.header.nextfile=OCNT.header.nextfile - (numel(CNT.data) - numel(OCNT.data)).*bytes - (length(CNT.electloc) - length(OCNT.electloc)).*75; % subtract data size AND electrode information
% OCNT.header.eventtablepos=OCNT.header.eventtablepos - (numel(CNT.data) - numel(OCNT.data)).*bytes - (length(CNT.electloc) - length(OCNT.electloc)).*75; % subtract data size AND electrode information
end % EDIT_CNTHEADER

function [ODATA]=EVAL_CHANOPS(DATA, CHLAB, OP)
%% DESCRIPTION:
%
%   Function to interpret and evaluate specified channel operation strings.
%   Notice that these data are first converted from their BDF format to a
%   microVolt signal according similar to BIOSIG.  
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
%   OP:     string, description of the mathematical operation to perform
%           (e.g., OP='(A1+A2)./2'; You'll notice that the channel labels
%           are used as variables here. 
%
% OUTPUT:
%
%   ODATA:  data output. Note that data matrix size will be CxT, where C is 
%           length of CHLAB. 
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
ODATA=eval([OP ';']); 

end % EVAL_CHANOPS