function hrtf_next(source,eventdata)

global H rds;

loc = get(H.loc,'value');

if loc<length(rds.thetaVec)
    set(H.loc,'value',loc+1);
else
    set(H.loc,'value',length(rds.thetaVec));
end

hrtf_update()