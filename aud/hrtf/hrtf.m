function hrtf(sub,thetaVec,opType)
% DESCRIPTION:
%
%   Generate a Head Related Transfer Function (HRTF) and Head Related
%   Impulse Response (HRIR) for a subject.
%
% INPUT:
%   sub:        string, subject ID (e.g., 'chris')
%   thetavec:   double array, azimuth angles (e.g., [-10:5:10])
%   opType:     string, type of stimulus to be used in HRTF recording.
%               (default='wn');
%               Current options include
%                   'wn': white-noise
%                   'pn': pink-noise
%                   'sweep': frequency sweep
%               Would like to add:
%                   'golay': suggested by Dennis Thompson at the IRC.
%                   'wightman': Named after Wightman (1989a/b) (multiple short bursts)
%
% OUTPUT:
%   rds:    Structure with recording information, see hrtf.m for field 
%       .Hdw:   microphone filters. Not used unless specified in    
%               hrtf_compute 
%       .fs:    integer, sampling frequency of recordings
%       .thetaVec:  recorded angles
%       .ref:   reference sound.
%       .sub:   string, subject ID
%       .itd:   estimate of Interaural Time Difference (ITD)
%       .ild:   estimate of Interaural Level Difference (ILD)
%       .rec:   raw recordings at each location.
%
%   hds:    structure with HRTF information.
%       .sub:       string, subject ID
%       .hrir:      time representation of HRTF
%       .hrtf:      frequency representation of HRIR
%       .thetaVec:  double array, recorded angles
%       .fs:        integer, sampling frequency of HRIR
%           NOTE: the FS of the HRIR and the source MUST match or things
%           won't work right (see hrtf_compute for details).
%
% Hill, Kevin (original version)
% Bishop, Chris 2009 made modifications listed below.
%   Extensive commenting and cleanup. Also modularized processing steps so
%   users could easily test different HRTF computation strategies.
%   090426CWB:  Added 'Cancel' Button if subject HRTF exists.

%% DECLARE RECORDING VARIABLES
% H is a structure recording handles and things only necessary for the GUI
%   .subPath:   path to subject directory.
%   .ai:    audio input device
%   .ao:    audio output device
%   .fig:   handle to GUI
%   .comp:
%   .ild:   estimate of Interaural Level Difference (ILD)
%   .itd:   estimate of Interaural Time Difference (ITD)
%   .next:  handle to button that calls hrtf_next
%   .rec:   raw recordings at each location.

% rds stores data about recordings/HRTF, with fields
%   .Hdw:   contains Finite Impulse Response (FIR) for each microphone.
%   .fs:    sampling rate (96000 Hz)
%   .thetaVec:  azimuth angles to be recorded (degrees)
%   .ref:   stimulus to be played during recordings (e.g., white-noise)
clear global H rds
global H rds;

%% DECLARE STIMULUS TYPE IF NOT DEFINED (default is white-noise)
if ~exist('opType') || isempty(opType) opType = 'wn'; end

pass=0;
while ~pass
    %% HRTFs will be stored in a user independent directory.
    H.subPath = ['C:\hrtfs\' sub '\'];
    %% Take care not to let subject overwrite existing HRTF data
    %% accidentally.
    if exist([H.subPath sub '-rds.mat'])
        response = questdlg(['A previous recording for ' sub ' already exists. Do you wish to load previous data, create a new subject ID, or overwrite old data?'],'Previous data detected','Load','New Subject','Overwrite','Cancel');
        switch response
            case 'Load'
                initFlag=0;
                pass=1;
                load([H.subPath sub '-rds.mat']);
            case 'New Subject'
                sub=char(inputdlg('Enter new subject ID','New ID',1,{[sub '_new']}));
            case 'Overwrite'
                initFlag=1;
                pass=1;
            case 'Cancel'
                return;
        end
    else
        initFlag=1;
        pass=1;
        if ~exist(H.subPath)
            mkdir(H.subPath)
        end
    end
end

if initFlag
    % Load filters and save with data
    load('mic-filters');
    rds.Hdw=Hdw;
    % Set variables
    rds.fs = 96000;
    rds.thetaVec=thetaVec;
    switch opType
        case 'sweep' 
            % Create FM sweep stimuli
            nsweep=302;
            t=1/rds.fs*[0:nsweep-1]';
            sweep = (chirp(t,50,nsweep/rds.fs,16000,'linear',90))*.5;
            % WINDOW SWEEP WITH trapez
            sweep = sweep.*trapez(length(sweep),0.02);
            pad=zeros(round(.0003*rds.fs),1);
            rds.ref = [pad;sweep;pad;pad;pad;pad;pad];
        case 'wn'
%             load('bpwn_3sec')
%             rds.ref = [zeros(500,1);bpwn;zeros(4000,1)];
            load('WHITENOISE_3sec', 'WHITENOISE');
            rds.ref = [zeros(500,1);WHITENOISE;zeros(4000,1)];
        case 'pn'
            load('bppn_3sec')
            rds.ref = [zeros(500,1);bppn;zeros(4000,1)];
        case 'speech'
            rds.ref = wavread('C:\Documents and Settings\khill\My Documents\Experiments\hrtfs\Chris_DA.wav');
        case 'golay'
            rds.ref = [zeros(500,1); wavread('golayA.wav'); zeros(4000,1)];
        otherwise
            error('Unknown hrtf opType, please use "sweep" or "wn"');
    end

    if rem(length(rds.ref),2)~=0
        rds.ref=[rds.ref;0];
    end
    %Init data for GUI updates, needed so update finds something to draw
    rds.sub=sub;
    rds.itd=repmat(nan,length(thetaVec),1);
    rds.ild=repmat(nan,length(thetaVec),1);
    rds.rec=zeros(length(rds.ref),2,length(thetaVec));
end

%% SETUP AUDIO I/O
hw=daqhwinfo('winsound');
iboard=strmatch('Fireface 800 Analog (7+8)',hw.BoardNames,'exact')-1;
% nrec=length(rds.ref)+8000;
nrec=1.5*length(rds.ref);
H.ai = analoginput('winsound',iboard);
H.ao = analogoutput('winsound');
set(H.ai,'StandardSampleRates','Off')
set(H.ao,'StandardSampleRates','Off')
addchannel(H.ai,1:2);
addchannel(H.ao,1:2);
set(H.ai,'SampleRate',rds.fs);
set(H.ao,'SampleRate',rds.fs);
set(H.ai,'SamplesPerTrigger',nrec)

%% CREATE GUI FOR HRTF RECORDING
H.fig  = figure;

%Plot Axes
H.comp = axes('Units','normalized','Position',[.08,.54,.87,.4]);
              title('Recs vs Ref');
H.ild  = axes('Units','normalized','Position',[.08,.08,.3,.35]);
              title('ILD');
              axis([min(thetaVec)-10 max(thetaVec)+10 -10 10]);
H.itd  = axes('Units','normalized','Position',[.45,.08,.3,.35]);
              title('ITD');
              axis([min(thetaVec)-10 max(thetaVec)+10 -1 1]);

%Plot GUI buttons
H.next  = uicontrol('Style', 'pushbutton','Tag','next', ...
                    'Units','normalized','FontUnits','normalized',...
                    'Position',[.8 .08 .15 .075],...
                    'String','Next',...
                    'Callback',@hrtf_next);
                
H.rec   = uicontrol('Style', 'pushbutton','Tag','rec', ...
                    'Units','normalized','FontUnits','normalized',...
                    'Position',[.8 .17 .15 .075],...
                    'String','Record');
switch opType
    case 'sweep'
        set(H.rec,'Callback',@hrtf_sweep_rec);
    case {'wn','pn'}
        set(H.rec,'Callback',@hrtf_rec);
    case {'golay'}
        set(H.rec,'Callback',@hrtf_golay_rec);
end
                          
H.loc   = uicontrol('Style', 'popupmenu','Tag','loc', ...
                    'Units','normalized','FontUnits','normalized',...
                    'Position',[.88 .31 .065 .006],...
                    'Max',1,'Min',1,...
                    'String',num2str([1:length(thetaVec)]'),...
                    'Callback',@hrtf_update);

%Don't bother getting handles for text, because it will be erased by
%redrawing the axes, so we'll just remake the text every update
text('Interpreter','tex','Tag','theta',...
     'Units','normalized','FontUnits','normalized',...
     'HorizontalAlignment','Left','FontSize',.2,...
     'Position',[1.2 .9],...
     'String',['\theta' ': ' num2str(thetaVec(1)) '\circ']);
text('Interpreter','tex','Tag','loctext',...
     'Units','normalized','FontUnits','normalized',...
     'HorizontalAlignment','Left','FontSize',.1,...
     'Position',[1.18 .62],...
     'String',['Loc #']);
                
hrtf_update();