function [rf,pcc]=RFgen_multichan(stimulus,data,Fs,RFdur,isSeed)

% The function prepares multichannel (e.g. EEG/MEG) epoched data for reverse
% correlation with auditory stimuli to generate a (spectro-) temporal response function [(S)TRF], per experimental condition, per channel.
% Estimation technique is boosting (http://informahealthcare.com/doi/abs/10.1080/09548980701609235)
% with 10-fold cross-validation
% The script is modified from N. Ding 2012 [gahding@umd.edu]
% by F. Cervantes Constantino 2012,2013 [fcc@umd.edu]
% and others in the Simon group.
% http://www.isr.umd.edu/Labs/CSSL/

%stimulus: A NxTxM matrix containing the auditory representations of the
%acoustic stimuli. N=number of frequency channels ; T=number of samples ;
%M=number of experimental conditions

%data: A CxTxM matrix of epoched, filtered, and averaged data. C=number of EEG/MEG channels ; T=number of samples ;
%M=number of experimental conditions

%Fs: The sampling frequency, corresponding to M samples in the stimuli and
%data. Default is 200 Hz

%RFdur: The duration of the RF to be modelled. Default is 1 s

%isSeed: Equals 1 if N>1, and frequency-band-wise reverse correlation is to be employed (which will initialize STRF estimation). Default seed is 0

%rf: A CxM cell array containing resulting Nxt response functions each. t=RFdur/Fs

%pcc: A CxM cell array containing the Pearson's correlation coefficient for
%the corresponding RF

%Last revision: 1 August 2013

if nargin<5; isSeed=0; end
if nargin<4; RFdur=1; end
if nargin<3; Fs=200; end
if nargin<2; error('Not enough arguments.'); end

No_Sti=size(stimulus,3);
No_Bnd=size(stimulus,1);
No_Chn=size(data,1);
try matlabpool
end

%% Prepare stimuli
sti=cell(1,No_Sti);
stdstim=cell(1,No_Sti);
for iStim = 1:No_Sti
    envl=squeeze(stimulus(:,:,iStim));
    stdstim{iStim}=std(envl,1);
    sti{iStim}=zscore(envl')';
end

%%Prepare responses
resp=cell(No_Chn,No_Sti);
stdresp=cell(No_Chn,No_Sti);
for iChan = 1:No_Chn
    for iResp = 1:No_Sti
        tpl=squeeze(data(iChan,:,iResp));
        stdresp{iResp}=std(tpl);
        tpl=zscore(tpl);
        resp{iChan,iResp}=tpl;
    end
end

%% Submit to boosting for RF estimation
rf=cell(No_Chn,No_Sti);
pcc=cell(No_Chn,No_Sti);
for iChan = 1:No_Chn
    for iRF = 1:No_Sti
        r=resp{iChan,iRF};
        seed=zeros(No_Bnd,RFdur*floor(Fs));
        if No_Bnd>1 && isSeed
            trfweights= stdstim{iRF}/max(stdstim{iRF});
            for iBand=1:No_Bnd;
                s=sti{iRF}(iBand,:);
                for sn=0:9
                    [trfcv(sn+1,:,:)]=svdboostV3pred(s,r,zeros(1,RFdur*floor(Fs)),0.005,1e3,sn);
                end
                seed(iBand,:)= trfweights(iBand)*(squeeze(mean(trfcv))');
            end
        end
        s=sti{iRF};
        for sn=0:9
            [hcv(sn+1,:,:),cr(sn+1)]=svdboostV3pred(s,r,seed,0.005,1e3,sn);
        end
        h=stdresp{iRF}*squeeze(mean(hcv));
        pcc{iChan,iRF}=mean(cr);
        rf{iChan,iRF}=h;
        clear trf* h* cr
    end
end
try matlabpool close
end