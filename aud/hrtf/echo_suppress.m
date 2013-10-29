function rdsES = echo_suppress(rds)

for loc = 1:size(rds.rec,3)
    for ch=1:2
        [y,i]=max(xcorr(rds.ref,rds.rec(:,ch,loc)));
        chOffset(ch)=length(rds.rec)-i;
        temp=[zeros(chOffset(ch)+round(.0003*rds.fs),1);ones(302,1);zeros(round(.0016*rds.fs),1)];
        sweepVec(:,2)=temp(1:size(rds.rec,1));
    end