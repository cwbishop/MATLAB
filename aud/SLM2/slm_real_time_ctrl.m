function slm_real_time_ctrl(obj,event)

global slmData

x=get(slmData.H.rtButton,'userdata');

if x
    stop(slmData.AI)
    
    % reset rt button
    set(slmData.H.rtButton,'userdata',0)
    set(slmData.H.rtButton,'string','Start')
    
    %if we are recording, need to stop it
    if slmData.recFlag
        slm_rec_ctrl;
    end
else
    %flush old data
    slmData.data = zeros(slmData.win,1);
    flushdata(slmData.AI);
    
    %restart and reset button
    start(slmData.AI)
    set(slmData.H.rtButton,'userdata',1)
    set(slmData.H.rtButton,'string','Stop')
end