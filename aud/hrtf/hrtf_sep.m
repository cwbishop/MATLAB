function [itd, ild, se, fv, level]=hrtf_sep(hrtf,fs,plotFlag)

if ~exist('plotFlag')||isempty(plotFlag)
    plotFlag = 0;
end

lowHz = 50;
highHz = 8000;
nchan=2;

%separate magnitude, phase, and frequency vector
mag=abs(hrtf);
ph=unwrap(angle(hrtf));
fv=linspace(0,fs,length(hrtf))';
fi=find(fv > lowHz & fv < highHz);

%extract itd as a linear delay between the ears
for ch=1:nchan
    fitCoef{ch} = polyfit(fv(fi),ph(fi,ch),1);
    fit(:,ch) = fitCoef{ch}(2)+fitCoef{ch}(1)*fv(fi);
end

if plotFlag, figure,plot(fv(fi),[ph(fi,:) fit]); end

itd=(fitCoef{1}(1)-fitCoef{2}(1))/(2*pi); %1-2 ensures that itd = lead time of left ear (+itd means left ear sooner)

%extract ild and se in dB
for ch=1:nchan
    %Pxxsm = log_smooth(mag(1:end/2,ch),fv(1:end/2),.01,3);
    Pxxsm = mag(1:end/2,ch);
    ilevel=find(fv > 125 & fv < 8000);
    magdb=20*log10(Pxxsm);%express the spectrum in decibles. 
    level(ch)=mean(magdb(ilevel));
    se(:,ch)=magdb-level(ch);
end

ild = diff(fliplr(level)); %fliplr to preserve ild of left relative to right (+ild mean left ear louder)

fv = fv(1:end/2);
    