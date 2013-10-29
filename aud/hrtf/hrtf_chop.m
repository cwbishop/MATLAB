function [PHbase,PHitd,MAGild,MAGse] =hrtf_chop(hds,indx);
%[PHbase,PHitd,MAGild,MAGse] =hrtf_chop(hds,indx);
%
%Chops up a full hrtf into its simplified components or itd, ild and se,
%the only information discarded is phase distortions which can contribute
%to echos, or non-symetric IRs.
%
%Output is a phase or magnitude component of an HRTF, as aplicable. PHbase
%represents a binaural delay, which helps put all IRs into positive time,
%simplifying convolutions.

if ~exist('indx') || isempty(indx)
    indx=[1:size(hds.hrtf,3)];
end

if max(indx)>size(hds.hrtf,3) || min(indx)<1
    disp('Malformed indx, using all locations');
    indx=[1:size(hds.hrtf,3)];
end

hspam.sub=hds.sub;
hspam.fs=hds.fs;
hspam.thetaVec=hds.thetaVec;

for loc=indx
    i=find(indx==loc);
    [itd, ild, se, fv]=hrtf_sep(hds.hrtf(:,:,loc),hds.fs);
    PHbase=(-55*2*pi/(length(fv)*2)).*[1:length(fv)*2]'-(-55*2*pi/(length(fv)*2)); %this should put things out 55 samples
    PHbase=[PHbase PHbase];
    
    delay=round(itd*hds.fs); %resample the itd to the resoultion of the IR, or else there will be distortions
    
    if itd<0 %left ear (channel 1) is later
        ph(:,2)=zeros(length(fv),1);
        ph(:,1)=(delay*2*pi/(length(fv)*2)).*[1:length(fv)]'-(delay*2*pi/(length(fv)*2));
    else %left ear (channel 1) is earlier, put the delay on ch 2
        ph(:,1)=zeros(length(fv),1);
        ph(:,2)=(-delay*2*pi/(length(fv)*2)).*[1:length(fv)]'-(-delay*2*pi/(length(fv)*2));
    end
    
    PHitd(:,:,i)=add_imag_phase(ph);
    
    tempILD=repmat([ild/2 -ild/2],length(fv),1); % ild = dB louder in left ear than right
    tempILD=10.^(tempILD/20); %switch to linear magnitude
    MAGild(:,:,i)=[tempILD;flipud(tempILD)]; %imaginary mag should be mirror of real mag
    
    tempSE=10.^(se/20);
    MAGse(:,:,i)=[tempSE;flipud(tempSE)];
end
    