function [HDR, HEADER, DATA]=bdf_read(P, HONLY)
%% DESCRIPTION:
%
%   Function to read in header information and raw data recorded in a BDF
%   file.
%
% INPUT:
%
%   P:  string, filename
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



%% READ IN HEADER INFORMATION

%% OPEN FILE POINTER
ptr=fopen(P, 'r'); 

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
ndrec=fread(ptr,8);     ndrec=char(ndrec'); 
ddrec=fread(ptr,8);     ddrec=char(ddrec');
nchan=fread(ptr,4);     nchan=(char(nchan'));
HDR.NCHAN=nchan;
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
nsam={};
for i=1:nchan, nsamp{i}=char(fread(ptr,8)'); end % i

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
% HDR.NCHAN=nchan;
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

%% READ IN DATA
DATA=[];
if ~HONLY, DATA=fread(ptr, 'ubit8'); end 
