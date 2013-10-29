function self_hrtf
global H rds


% beep
pause(6)

nlocs = length(get(H.loc,'String'));

for loc =1:nlocs
    set(H.loc,'value',loc);
    hrtf_rec();
    pause(3);
end

% pause(5)
% beep
% pause(5)
% nlocs = length(get(H.loc,'String'));
% rds.rec=[];
% for loc = 1:nlocs
%     set(H.loc,'value',loc);
%     if loc==1
%         rds.ref=wavread('golayA.wav');
%     else
%         rds.ref=wavread('golayB.wav');
%     end
%     rec=[];
%     putdata(H.ao,[rds.ref zeros(length(rds.ref),1)]);
%     start(H.ai)
%     start(H.ao)
%     rec=getdata(H.ai);
%     rds.rec(:,:,loc)=rec;
%     pause(1);
%     
% end
