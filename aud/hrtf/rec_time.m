function [rec,fs] = rec_time(time,fs);
%[rec,fs] = rec_time(time,fs)
%Record any arbitrary length of time (in seconds) at specified fs
%If no fs is specified, the default is 44.1kHz

if ~exist('fs') || length(fs)==0
    fs = 44100;
end

ai = analoginput('winsound');
set(ai,'StandardSampleRates','Off')
addchannel(ai,1);
set(ai,'SampleRate',fs);
fs=get(ai,'SampleRate');

recSamps=fs*time;
set(ai,'SamplesPerTrigger',recSamps)

start(ai)

rec=getdata(ai);

stop(ai)