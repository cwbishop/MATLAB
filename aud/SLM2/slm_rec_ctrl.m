function slm_rec_ctrl(obj,event)

global slmData

if slmData.recFlag
    %stop the rec and save it to the workspace
    slmData.recFlag=0;
    set(slmData.H.recText,'foregroundcolor',[0 0 0])
    set(slmData.H.recButton,'string','Rec')
else
    %clear any old rec, and set the rec flag
    slmData.rec=[];
    slmData.recFlag=1;
    
    %if we aren't running, we need to be
    if ~get(slmData.H.rtButton,'userdata')
        slm_real_time_ctrl;
    end
    set(slmData.H.recButton,'string','Stop Rec')
end