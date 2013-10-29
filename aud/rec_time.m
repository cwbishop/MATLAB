function [rec,fs] = rec_time(time,fs,in_device,channels)
% [rec,fs,rec_timing,rec_abs,rec_events,toc_end] = rec_time(time,fs,in_device);
%record any arbitrary length of time at specified fs

if ~exist('fs','var') || isempty(fs) 
    fs = 48000;
end
if ~exist('in_device','var') || isempty(in_device)
    in_device = 0;
end
if ~exist('channels','var') || isempty(channels)
    channels = 1;
end

recSamps=fs*time;
ai = analoginput('winsound',in_device);
set(ai,'StandardSampleRates','Off')
addchannel(ai,1:2);
set(ai,'SampleRate',fs);
fs=get(ai,'SampleRate');
set(ai,'SamplesPerTrigger',recSamps)

start(ai)
rec=getdata(ai);
rec = rec(:,channels);
flushdata(ai,'all');
stop(ai)
delete(ai)