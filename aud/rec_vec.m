function [rec_lat,fs] = rec_vec(file,fs,in_device, out_device, correction,channels)
%%%[rec_lat,fs] = rec_vec(file,fs,device,latency);
%Record any arbitrary vector at specified fs
%Correction is a latency correction for a delay in sound card output (0.003
%is a good approximation)
%If no fs is specified, the default is 44.1kHz

if ~exist('fs','var') || isempty(fs) 
    fs = 48000;
end
if ~exist('in_device','var') || isempty(in_device)
    in_device = 0;
end
if ~exist('out_device','var') || isempty(out_device)
    out_device = 0;
end
if ~exist('correction','var') || isempty(correction)
    correction = 0;
end
if ~exist('channels','var') || isempty(channels)
    channels = 1;
end


lat = ceil(fs*correction);
ai = analoginput('winsound',in_device);
ao = analogoutput('winsound',out_device);
set(ai,'StandardSampleRates','Off')
set(ao,'StandardSampleRates','Off')
addchannel(ai,1:2);
addchannel(ao,1:2);
set(ai,'SampleRate',fs);
set(ao,'SampleRate',fs);
fs=get(ai,'SampleRate');

if size(file,2)==1,file=[file file];end
recSamps=length(file)+lat;
%recSamps=length(file);

set(ai,'SamplesPerTrigger',recSamps)

putdata(ao,file);
start(ai)
start(ao)
rec=getdata(ai);
rec_lat = rec(lat+1:length(rec),channels);
flushdata(ai,'all');
stop(ai)
stop(ao)
delete(ai)
delete(ao)

