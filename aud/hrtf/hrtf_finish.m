function hrtf_finish(source,eventdata)
% Hill, Kevin
%   Minor fixes by CWB.

global rds

%% GUI SELECTION OF INPUT OPTIONS TO HRTF_COMPUTE
l=strvcat('NONE','SM', 'NR', 'MF');
[SEL]=listdlg('PromptString', 'Select hrtf_compute INPUTS',...
'ListString',  l);
if SEL==1 || isempty(SEL), l=[]; else l=l(SEL,:); end

%% COMPUTE HRTF
%   If the HRTF is very large (beyond about 19 points), each point must be
%   estimated separately.  As a result, Normalization (NR) inputs will be
%   ignored.
% if size(rds.rec,3)>10
    % EXCLUDE NR
%     warning('ESTIMATING EACH POINT INDIVIDUALLY');
%     l=l(l~=3);
    for i=1:size(rds.rec,3)
        in.sub=rds.sub; in.Hdw=rds.Hdw; in.fs=rds.fs; 
        in.thetaVec=rds.thetaVec(i); in.ref=rds.ref;
        in.itd=rds.itd(i); in.ild=rds.ild(i);
        in.rec=rds.rec(:,:,i);
        [OUT BASE]=hrtf_compute(in,l,20000);
        hds.sub=OUT.sub;
        hds.fs=OUT.fs;
        hds.hrir(:,:,i)=OUT.hrir;
        hds.hrtf(:,:,i)=OUT.hrtf;
        hds.thetaVec(i)=OUT.thetaVec;
        clear in OUT;
    end % i.
% else
%     [hds BASE]=hrtf_compute(rds, l, 20000);
% end

%% NORMALIZE HRIR
% 1. Estimate bandpassed white noise (BPWN) at 0 degrees azimuth.  
% 2. Determine scaling factor.
% 3. Apply scaling factor to HRIR at all positions. 
%
% This assumes your stimuli have a maximum value of 0.90.  This might
% change depending on the stimulus set, so you might have to modify the
% constant.
if ~isempty(strmatch('NR', l))
    display('Normalizing HRIRs')
    load('bpwn_3sec')    
    [pout, out]=hrtf_filt(hds,0,bpwn);
    % 091025 CB
    %   Needed to make sounds louder. Also, I was getting a little worried
    %   that we might be pushing the HRIR down to the level of quanta,
    %   which would do all sorts of weird things to our stimuli.  
    %     sc=0.008/mean(rms(out));
%     sc=0.0450/mean(rms(out)); 
    sc=0.0253/mean(rms(out)); 
    hds.hrir=hds.hrir.*sc;
    hds.hrtf=fft(hds.hrir);
end 
%% SAVE DATA
save([BASE '-rds'],'rds');
save([BASE '-hds'],'hds');


%% FINISH UP
%   Clear variables and close figure.
clear rds
global H;
close(H.fig)
clear global H rds BASE
