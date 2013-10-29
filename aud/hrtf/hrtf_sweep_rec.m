function hrtf_sweep_rec(source,eventdata)

global H rds;

loc=get(H.loc,'value');

%Record 10 repitions of the sweeps then time average them.
rec=[];
for rep=1:10
    putdata(H.ao,[rds.ref zeros(length(rds.ref),1)]);
    start(H.ai)
    start(H.ao)
    rec(:,:,rep)=getdata(H.ai);
    for ch=1:2
        [y,i]=max(xcorr(rds.ref,rec(:,ch,rep)));
        chOffset(ch)=length(rec)-i;
    end
    offset=min(chOffset)-40; % subtract 20 here so that nothing is occuring in negative time
    rec_mv(:,:,rep)=rec(offset:offset-1+length(rds.ref),:,rep);
end
rec_avg(:,:)=mean(rec_mv,3);
rec_avg=detrend(rec_avg,'constant'); %remove the mean value from the average

%compute ITD and ILD and put rec in rds for storage
for ch=1:2
    [y,i]=max(xcorr(rds.ref,rec_avg(:,ch)));
    chOffset(ch)=length(rec_avg)-i;
end
rds.itd(loc)=diff(chOffset)/rds.fs*10^6;

rds.rec(:,:,loc)=(rec_avg./max(max(abs(rec_avg))))*.5; % again, why are we doing this? Don't we need these cues??
rec_rms=rms(squeeze(rds.rec(:,:,loc)));
rds.ild(loc)=20*log10(rec_rms(1)/rec_rms(2));

%update the display to show results of rec
hrtf_update();

save([H.subPath rds.sub '-recs'],'rds');