function [HDR, HEADER, HEADEROUT, DATA]=bdf_trim(IN, OUT, CHANNELS)
%% DESCRIPTION:
%
%   Reads in a BIOSEMI BDF, extracts the specified channels, and writes
%   trimmed BDF to file. 
%
% INPUT:
%
%   IN:  string, path to original BDF.
%   OUT: string, path to trimmed BDF.
%   CHANNELS:   character array of channels to include (e.g. strvcat('A1',
%               'A2', 'Status')). Note: the 'Status' channel is NOT
%               included by default. 
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
%       DDREC:  duration of data record in seconds (8 byes)
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
%   DATA:   trimmed data. Stored in native BDF format.
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu



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
DATA=[];

% select channels
IND=ismember(cell2mat(HDR.CHLAB'), CHANNELS, 'rows');
IND=find(IND~=0); 
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
%   Trim data and all relevant header fields. 


% fclose(ptr); 

for c=1:length(IND)
    ind=IND(c);         
    % Set header information
    chlab=[chlab bp(HDR.CHLAB{ind},16)];
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
nbytes=8+80+80+8+8+8+44+8+8+4+size(CHANNELS,1)*16+size(CHANNELS,1)*8*6+80*size(CHANNELS,1)*2+size(CHANNELS,1)*32;

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
    bp(num2str(size(CHANNELS,1)),4) ...
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
    data=fread(ptr, sum(HDR.NSAMP), 'bit24');     
    
    % TRIM
    for c=1:length(IND)
        ind=IND(c); 
        % Get data
%         DATA=[DATA; data(1+ ((sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)):(sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)+ (sum(HDR.NSAMP)/HDR.NCHAN))];
        fwrite(optr, data(1+ ((sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)):(sum(HDR.NSAMP)/HDR.NCHAN)*(ind-1)+ (sum(HDR.NSAMP)/HDR.NCHAN)), 'bit24');
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
