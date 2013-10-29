function rec_log(time,fs,in_device,filename);
%rec_log(time,fs,in_device,filename, mode);
%record any arbitrary length of time at specified fs and device number 
%See find_dev to find the device number 
%(ie rec_log(2,96000,[15],'C:\Documents and Settings\jrkerlin\Desktop\Timing\test')


if ~exist('fs') || length(fs)==0 
    fs = 96000;
end

if ~exist('in_device')
    in_device = 0;
end

if ~exist('filename')
    filename = tempname();
end


recSamps=fs*time;
for idx = 1:length(in_device)
clear ai
ai = analoginput('winsound',in_device(idx));
set(ai,'StandardSampleRates','Off')
addchannel(ai,1:2);
set(ai,'SampleRate',fs);
fs=get(ai,'SampleRate');
set(ai,'SamplesPerTrigger',recSamps)
set(ai,'TriggerType','Manual');
set(ai,'ManualTriggerHwOn','Trigger');
ai.LogFileName = [filename num2str(idx)];
ai.LogToDiskMode = 'overwrite';
ai.LoggingMode = 'Disk';
ai_dev{idx} =  ai;
end
ai_string = [];
for i = 1:length(in_device)
ai_string = [ai_string 'ai_dev{' num2str(i) '} '];
stop(ai_dev{i})
start(ai_dev{i})
end
tic
eval(['trigger([' ai_string '])'])
%trigger([ai_dev{1} ai_dev{2}])
% for j = 1:length(in_device)
%     wait(ai_dev{j},time+.5)
% end
% toc_end = toc
% 
% clear_daq;
% for m = 1:length(in_device)
% [rec{m},rec_timing{m},rec_abs{m},rec_events{m}] = getdata(ai_dev{m},time*fs);
% end

% if length(in_device) == 1
%     rec = rec{1};
% end