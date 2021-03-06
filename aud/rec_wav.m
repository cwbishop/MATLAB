function [rec,fs] = rec_wav(file,fs);
%[rec,fs] = rec_wav(file,fs)
%record any arbitrary .wav file at specified fs

if isempty(fs)
    fs = 44100;
end

ai = analoginput('winsound');
ao = analogoutput('winsound');
set(ai,'StandardSampleRates','Off')
set(ao,'StandardSampleRates','Off')
addchannel(ai,1);
addchannel(ao,1:2);
set(ai,'SampleRate',fs);
set(ao,'SampleRate',fs);
fs=get(ai,'SampleRate');

[wav,tempFs] = wavread(file);

if tempFs ~= fs, wav = resample(wav,fs,tempFs); end
if size(wav,2)==1,wav=[wav wav];end

recSamps=length(wav)+ceil(.5*fs);

set(ai,'SamplesPerTrigger',recSamps)

putdata(ao,wav);
start(ai)
start(ao)

rec=getdata(ai);