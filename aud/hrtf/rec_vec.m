function [rec,fs] = rec_vec(file,fs);
%[rec,fs] = rec_vec(file,fs)
%Record any arbitrary vector at specified fs
%If no fs is specified, the default is 44.1kHz

if ~exist('fs') || length(fs)==0
    fs = 44100;
end

ai = analoginput('winsound');
ao = analogoutput('winsound');
set(ai,'StandardSampleRates','Off')
set(ao,'StandardSampleRates','Off')
addchannel(ai,1:2);
addchannel(ao,1:2);
set(ai,'SampleRate',fs);
set(ao,'SampleRate',fs);
fs=get(ai,'SampleRate');

if size(file,2)==1,file=[file file];end

recSamps=length(file)+ceil(.5*fs);

set(ai,'SamplesPerTrigger',recSamps)

putdata(ao,file);
start(ai)
start(ao)

rec=getdata(ai);