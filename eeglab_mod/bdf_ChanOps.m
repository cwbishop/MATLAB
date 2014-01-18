function [HDR, HEADER, HEADEROUT, DATA]=bdf_ChanOps(IN, OUT, CHANOPS, OCHLAB)
%% DESCRIPTION:
%
%   Performs channel operations on Biosemi Data Files (BDFs).  This proved
%   useful when files are too big to open in their entirety due to high
%   sampling rates or long experiment times. 
%
%   At its core, this function operates much as bdf_trim did, but in a much
%   more flexible way. That is, this function can be used to trim files or
%   perform more complex operations, like averaging over channels, etc.
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
%
% OUTPUT:
%
%   HDR:    structure with the following fields
%       IDCODE: identification code (8 bytes)
%       LSID:   local subject identification (80 bytes)
%       LRID:   local recording identification (80 bytes)
%       SDATE:  start date (8 bytes)
%       STIME:  start time (8 bytes)
%       NBYTES: number of bytes in header (8 bytes)
%       VDFRM:  version data format (44 bytes; "24BIT" for BDF)
%       NDREC:  number of data records (8 bytes)
%       DDREC:  duration of data record in seconds (8 bytes)
%       NCHAN:  number of channels (4 bytes)
%       CHLAB:  channel labels (Nx16 bytes)
%       TTYPE:  transducer type (Nx80bytes)
%       PHDIM:  physical dimension of channels (Nx8 bytes)
%       PHMIN:  physical minimum in units (Nx8 bytes)
%       PHMAX:  physical maximim in units (Nx8bytes)
%       DGMIN:  digital minimum (Nx8 bytes)
%       DGMAX:  digital maximum (Nx8 bytes)
%       PRFLT:  prefiltering (Nx80 bytes)
%       NSAMP:  Number of samples in each data record (i.e. sample rate if
%               DDREC=1 sec; Nx8 bytes)
%       RESRV:  reservered (Nx32 bytes)
%
%   HEADER: header string of INput file.
%   HEADEROUT:  header string of OUTput file.
%   DATA:   Operated data.
%
%
% NOTES:
%
%   120626CWB:  Function tested to read and write file as is (first pass
%               sanity check). Linux command line "diff" function shows
%               that original file is identical to output from
%               bdf_ChanOps.m.  
%
%               IN='s3188/eeg/s3188_PEABR_Exp02C (6.79 msec).bdf'; 
%               OUT='s3188/eeg/s3188_bdf_chanops.bdf'; 
%               CHANOPS={'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'EXG1' 'EXG2' 'EXG3' 'EXG4' 'Status'}; 
%               OCHLAB={'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'EXG1' 'EXG2' 'EXG3' 'EXG4' 'Status'};
%
%   120704CWB:  Substantial rewrite of function, including addition of
%               several smaller functions (e.g. BDF2DATA).  Ran the command
%               above to read in a file and rewrite it with no changes
%               made. This led to no differences using the "diff" command.
%
%   120704CWB:  Testing with average of first 6 channels and a single 
%               channel reference.
%               IN='s3188/eeg/s3188_PEABR_Exp02C (6.79 msec).bdf'; 
%               OUT='s3188/eeg/s3188_bdf_chanops.bdf'; 
%               CHANOPS={'(A1+A2+A3+A4+A5+A6)./6' 'EXG1' 'Status'}; 
%               OCHLAB={'Vertex' 'Reference' 'Status'};
%
%               These data look great, but will NOT match EEGLAB perfectly.  
%               I fiddled around with this and it
%               seems this is PROBABLY because BDFs have an inherent
%               maximum resolution of ~0.0312 uV (at 24 bit resolution),
%               while MATLAB has much greater precision when doing
%               averaging, even with SINGLE precision.  
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

%% INPUT CHECK
%   If Output CHannel LABels is not defined, is empty, or doesn't match the
%   length of CHANOPS, define OCHALAB automatically. 
if ~exist('OCHLAB', 'var') || isempty(OCHLAB) || length(OCHLAB) ~= length(CHANOPS)
    OCHLAB={};
    for c=1:length(CHANOPS)
        OCHLAB{c}=['CH' num2str(c)];
    end % c
end % if 

% Check to make sure OCHLAB data are under 16 bytes (16 characters)
for c=1:length(OCHLAB)
    if length(OCHLAB{c})>16
        error('OCHLAB cannot exceed 16 bytes.');
    end % if length
end % c

%% READ IN HEADER INFORMATION

%% OPEN FILE POINTER
ptr=fopen(IN, 'r'); 

%% READ IN NUMBER OF BYTES
fseek(ptr, 184, 'bof'); 
nbytes=fread(ptr, 8); 
HDR.NBYTES=str2num(char(nbytes'));

%% READ IN WHOLE HEADER
frewind(ptr);
HEADER=fread(ptr, HDR.NBYTES);

%% READ IN INDIVIDUAL FIELDS
%   Might seem silly to rewind the pointer, but it's better than me typing
%   out values and indices into HEADER a lot. That's a sure way for me to
%   screw something up.
frewind(ptr);
idcode=fread(ptr,8);    idcode=char(idcode'); 
lsid=fread(ptr,80);     lsid=char(lsid');
lrid=fread(ptr,80);     lrid=char(lrid'); 
sdate=fread(ptr,8);     sdate=char(sdate');
stime=fread(ptr,8);     stime=char(stime');
nbytes=fread(ptr,8);    nbytes=char(nbytes'); 
vdfrm=fread(ptr,44);    vdfrm=char(vdfrm'); 
ndrec=fread(ptr,8);     ndrec=str2num(char(ndrec')); 
ddrec=fread(ptr,8);     ddrec=char(ddrec');
nchan=fread(ptr,4);     nchan=(char(nchan'));
nchan=str2num(nchan); 

% channel labels
chlab={};
for i=1:nchan, chlab{i}=char(fread(ptr,16)'); end % i

% transducer type
ttype={};
for i=1:nchan, ttype{i}=char(fread(ptr,80)'); end % i

% physical dimensions
phdim={};
for i=1:nchan, phdim{i}=char(fread(ptr,8)'); end % i

% physical minimum
phmin={};
for i=1:nchan, phmin{i}=char(fread(ptr,8)'); end % i

% physical maximum
phmax={};
for i=1:nchan, phmax{i}=char(fread(ptr,8)'); end % i

% digital minimum
dgmin={};
for i=1:nchan, dgmin{i}=char(fread(ptr,8)'); end % i

% digital maximum
for i=1:nchan, dgmax{i}=char(fread(ptr,8)'); end % i

% pre-filtering
prflt={};
for i=1:nchan, prflt{i}=char(fread(ptr,80)'); end % i

% number of samples
nsamp=[];
for i=1:nchan, nsamp(i,1)=str2num(char(fread(ptr,8)')); end % i

% reserved
resrv={};
for i=1:nchan, resrv{i}=char(fread(ptr,32)'); end % i

HDR.IDCODE=idcode; 
HDR.LSID=lsid; 
HDR.LRID=lrid;
HDR.SDATE=sdate;
HDR.STIME=stime;
HDR.NBYTES=nbytes;
HDR.VDFRM=vdfrm;
HDR.NDREC=ndrec;
HDR.DDREC=ddrec;
HDR.NCHAN=nchan;
HDR.CHLAB=chlab;
HDR.TTYPE=ttype;
HDR.PHDIM=phdim;
HDR.PHMIN=phmin;
HDR.PHMAX=phmax;
HDR.DGMIN=dgmin;
HDR.DGMAX=dgmax;
HDR.PRFLT=prflt;
HDR.NSAMP=nsamp;
HDR.RESRV=resrv;

%% READ IN SELECTED DATA
% DATA=[];

% select channels
% IND=ismember(cell2mat(HDR.CHLAB'), CHANNELS, 'rows');
% IND=find(IND~=0); 
chlab=[];
ttype=[];
phdim=[];
phmin=[];
phmax=[];
dgmin=[];
dgmax=[];
phmax=[];
prflt=[];
nsamp=[];
resrv=[];

%% CREATE OUTPUT DATA
%   Trim data and all relevant header fields. % fclose(ptr); 

for c=1:length(CHANOPS)
%     ind=IND(c);         
    
    % Find a channel included in CHANOPS (necessary to determine tranducer
    % type and other header parameters. 
    %   NOTE: We have to assume tranducers are of the same type.
    tchlab=cell2mat(HDR.CHLAB');
    for i=1:length(tchlab)
        if ~isempty(strfind(CHANOPS{c}, deblank(tchlab(i,:))))
            ind=i;
            break;
        end % if ~isempty ...       
    end % 
    
    % HDRO necessary later for writing data
    HDRO.CHLAB{c}=OCHLAB{c}; % channel label
    HDRO.PHMIN{c}=HDR.PHMIN{ind}; % physical min
    HDRO.PHMAX{c}=HDR.PHMAX{ind}; % physical max
    HDRO.DGMIN{c}=HDR.DGMIN{ind}; % digital min
    HDRO.DGMAX{c}=HDR.DGMAX{ind}; % digital max
    
    % Set header information
    chlab=[chlab bp([OCHLAB{c}],16)];
    ttype=[ttype bp(HDR.TTYPE{ind},80)];
    phdim=[phdim bp(HDR.PHDIM{ind},8)];
    phmin=[phmin bp(HDR.PHMIN{ind},8)];
    phmax=[phmax bp(HDR.PHMAX{ind},8)];
    dgmin=[dgmin bp(HDR.DGMIN{ind},8)];
    dgmax=[dgmax bp(HDR.DGMAX{ind},8)];
    prflt=[prflt bp(HDR.PRFLT{ind},80)];
    nsamp=[nsamp bp(num2str(HDR.NSAMP(ind)),8)];
    resrv=[resrv bp(HDR.RESRV{ind},32)];     
end % 
nbytes=8+80+80+8+8+8+44+8+8+4+length(CHANOPS)*16+length(CHANOPS)*8*6+80*length(CHANOPS)*2+length(CHANOPS)*32;

%% CONSTRUCT OUTPUT HEADER
HEADEROUT=[];

nchan=[];
HEADEROUT=[...
    bp(HDR.IDCODE,8) ... % annoying story, I know this is 7 though.
    bp(HDR.LSID,80) ...
    bp(HDR.LRID,80) ...
    bp(HDR.SDATE,8) ...
    bp(HDR.STIME,8) ...
    bp(num2str(nbytes),8) ...
    bp(HDR.VDFRM,44) ...
    bp(num2str(HDR.NDREC),8) ...
    bp(HDR.DDREC,8) ...
    bp(num2str(length(CHANOPS)),4) ...
    chlab ...
    ttype ...
    phdim ...
    phmin ...
    phmax ...
    dgmin ...
    dgmax ...
    prflt ...
    nsamp ...
    resrv];

%% WRITE DATA TO FILE
optr=fopen(OUT, 'w'); 

% Write header.
% fwrite(ptr, HEADEROUT, 'bit8'); 
% This is an annoying bug I couldn't get around. Had to hard code it,
% frustrating. 
fwrite(optr, str2num('255'), 'ubit8');
fwrite(optr, HEADEROUT(2:end), 'ubit8'); 

for i=1:HDR.NDREC    
    
    % READ IN SECOND OF DATA
    data=single((fread(ptr, sum(HDR.NSAMP), 'bit24')));     
    
    % TRIM
    for c=1:length(CHANOPS)
%         ind=IND(c); 
        % Get data
%         DATA=[DATA; data(1+ ((sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)):(sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)+ (sum(HDR.NSAMP)/HDR.NCHAN))];
%         DATA=data(1+ ((sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)):(sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)+ (sum(HDR.NSAMP)/HDR.NCHAN));
        
        % Need some basic header information
        names=fieldnames(HDRO);
        for z=1:length(names)
            hdro.(names{z}){1}=HDRO.(names{z}){c};
        end % z
        
        % DO CHANNEL OPERATION
        [DATA]=EVAL_CHANOPS(data, HDR, CHANOPS{c}, hdro);
        
        % Write data to disk
        fwrite(optr, DATA, 'bit24');
    end % 
end % i

% Write data
% fwrite(ptr, DATA, 'bit24'); 

% Close file
fclose(ptr); 
fclose(optr);
end % bdf_trim

function [STR]=bp(STR, N)
%% DESCRIPTION:
%
%   Pad a string with blanks to length N.
%
% INPUT:
%
%   STR:    string input
%   N:      length the string should ultimately be.
%
% OUTPUT:
%
%   STR:    blank padded string.
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

    STR=[STR blanks(N-length(STR))];
    
end % function blank_pad

function [ODATA]=EVAL_CHANOPS(DATA, HDR, OP, HDRO)
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
%   DATA:   Raw data from BDF
%   HDR:    BDF header structure.
%   OP:     string, channel operation to carry out. Can contain function
%           calls (e.g. mean(), sum(), etc.) or other operations (e.g.
%           (A1+A2)./2 to average over channels A1 and A2.
%           *Note*: Data variables will be named as their channel labels in
%           the original BDF. 
%
% OUTPUT:
%
%   ODATA:  Transformed BDF data.
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2012
%   cwbishop@ucdavis.edu

% CONVERT DATA INTO MICROVOLTS
DATA=BDF2DATA(DATA, HDR, false); % Confirmed that conversion is OK

% I think this is a safe assumption, since the function above tries to take
% other parameters into account.
ODATA=[];
dsize=length(DATA)./length(HDR.CHLAB); % data size (dsize)

% First, assign DATA to variables. Variables will be named after the
% channel labels
%
%   Single data are read in with SINGLE precision, need to keep that...I
%   think.
%
%   Actually, dunno if that matters at all. 
for c=1:length(HDR.CHLAB)
    eval([HDR.CHLAB{c} '=[];']); 
    eval([HDR.CHLAB{c} '=single(DATA(1+(c-1)*dsize : (c-1)*dsize + dsize));']);    
end % c=1:length(HDR.CHLAB)

% Evaluate channel operation
eval('ODATA=eval(OP);'); 

% CONVERT DATA2BDF 
ODATA=BDF2DATA(ODATA, HDRO, true); 

end % EVAL_CHANOPS

function ODATA=BDF2DATA(DATA, HDR, DATA2BDF)
%% DESCRIPTION:
%
%   The data stored in BDF format must be massaged into microvolts using
%   information from the header. Much of what is done here is based off of
%   BIOSIG's sopen/sread functions, which I cannibalized to write 
%   bdf_write.m.  I wanted a stand alone function, so I didn't use BIOSIG
%   toolbox. Plus, the BIOSIG toolbox, although useful, is nearly
%   impossible to dig into. 
%
%   Will also do the reverse operation, converting microvolts back into BDF
%   units. 
%
%   Note: BDF2DATA will not match data EEGLAB's EEG.data field because
%   BDFs have a native precision of ~0.0312 uV. MATLAB has better
%   precision.
%
% INPUT:
%
%   BDF:    BDF format data.
%   HDR:    HDR structure. Only needs the following fields, which are
%           required for transforming the data to and to BDF format. 
%               .PHMAX
%               .PHMIN
%               .DGMAX
%               .DGMIN
%               .CHLAB
%   DATA2BDF:   bool, converts data (microvolts) to BDF format (default=0);
%
% OUTPUT:
%
%   DATA:   
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2012
%   cwbishop@ucdavis.edu

% INPUT CHECK
if ~exist('DATA2BDF', 'var') || isempty(DATA2BDF), DATA2BDF=false; end 

% DATA CHUNK SIZE
%   I made this assumption in EVAL_CHANOPS...I think this is a fair
%   assumption. 
% ODATA=nan(size(DATA)); % populate with NaNs first, easy to spot screwed up indices
dsize=length(DATA)./length(HDR.CHLAB); % data size (dsize)

% CALCULATE SCALING FACTOR AND OFFSETS, CONVERT DATA
%   Derived from sopen.m line 582
%   HDR.Cal = (HDR.PhysMax-HDR.PhysMin)./(HDR.DigMax-HDR.DigMin);    
for c=1:length(HDR.CHLAB)
    CAL(c,1)=(str2double(HDR.PHMAX{c})-str2double(HDR.PHMIN{c}))./(str2double(HDR.DGMAX{c})-str2double(HDR.DGMIN{c}));
    OFF(c,1)=(str2double(HDR.PHMIN{c}) - (CAL(c,1) .* str2double(HDR.DGMIN{c})));
    
    % Transform data, assign to output variable.
    %   *NOTE*: We convert to double to maintain precision, as is done in
    %   BIOSIG's sread function.
    %
    %   Transformation based borrowed from 
    %       sopen.m 618
    %           HDR.Calib  = [HDR.Off; diag(HDR.Cal)];
    %       sread 1537-1540
    %           for k = 1:size(Calib,2),
    %                   chan = find(Calib(2:end,k));
    %                   S(:,k) = double(tmp(:,chan)) * full(Calib(1+chan,k)) + Calib(1,k);
    %           end;
    
    % Data index    
    IND=1+(c-1)*dsize : (c-1)*dsize + dsize;
    
    % Double precision
%     DATA=double(DATA);
    % Convert to or from BDF?
    %   Convert BDF2DATA by default
    if ~DATA2BDF
        ODATA(IND)=(DATA(IND)).*CAL(c) + OFF(c); 
    else
        ODATA(IND)=round((DATA(IND)-OFF(c))./CAL(c)); 
    end % if ~DATA2BDF
end % c

end % bdf2data