function hrtf_update(source,eventdata)
% DESCRIPTION:
%
%   Update GUI during HRTF acquisition.
%
% Hill, Kevin

global H rds;

thetaVec=rds.thetaVec;

loc=get(H.loc,'value');

nloc=length(thetaVec);

if loc==nloc
    set(H.next,'String','Done','Callback',@hrtf_finish);
else
    set(H.next,'String','Next','Callback',@hrtf_next);
end

plot(H.comp,[rds.ref squeeze(rds.rec(:,:,loc))]);
title(H.comp,'Recs vs Ref');

plot(H.ild,rds.thetaVec,rds.ild,'b*')
hold(H.ild,'on')
plot(H.ild,rds.thetaVec(loc),rds.ild(loc),'r*')
title(H.ild,'ILD')
hold(H.ild,'off')

plot(H.itd,rds.thetaVec,rds.itd,'b*')
hold(H.itd,'on')
plot(H.itd,rds.thetaVec(loc),rds.itd(loc),'r*')
title(H.itd,'ITD')
hold(H.itd,'off')

text('Interpreter','tex','Tag','loctext',...
     'Units','normalized','FontUnits','normalized',...
     'HorizontalAlignment','Left','FontSize',.1,...
     'Position',[1.18 .62],...
     'String',['Loc #']);

text('Interpreter','tex','Tag','theta',...
     'Units','normalized','FontUnits','normalized',...
     'HorizontalAlignment','Left','FontSize',.2,...
     'Position',[1.2 .9],...
     'String',['\theta' ': ' num2str(thetaVec(loc)) '\circ']);