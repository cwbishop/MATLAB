function slm_update(obj,event)

global slmData

%% Get the newest data
samps=get(obj,'SamplesAvailable');
tempdata=getdata(obj,samps);
tempdata=tempdata(:,1);

%why do we sometimes get NANs? it seems there are orriginating before they
%get save in the AI buffer. always on the same sample too!

%so we just need to take care of them
inan=find(isnan(tempdata));
for i=1:length(inan)
    tempdata(inan(i))=(tempdata(inan(i)-1)+tempdata(inan(i)+1))/2; %this will work as long as we don't have 2 nans in a row... which i haven't seen yet
end

slmData.data=[slmData.data;tempdata];
slmData.data=slmData.data(end-(slmData.win-1):end); %the win-1 if for indexing

%if we're recording, update the rec
if slmData.recFlag
    slmData.rec=[slmData.rec;tempdata];
    assignin('base','rec',slmData.rec);
end

%estimate dB
slmData.dB=20*log10(rms(slmData.data)*sqrt(2))+slmData.cal; % 1/sqrt(2) is the rms of a pure tone with an amplitude of 1

%compute pxx
[slmData.pxx slmData.fv]=pwelch(slmData.data,[],[],[],slmData.fs);
slmData.pxx=10*log10(slmData.pxx)+slmData.cal;

%% Update the figures
plot(slmData.H.timePlot,slmData.data);
axis(slmData.H.timePlot,[0 slmData.win -1 1]);

plot(slmData.H.pxxPlot,slmData.fv,slmData.pxx);
set(slmData.H.pxxPlot,'xscale','log');
axis(slmData.H.pxxPlot,[5 slmData.fs/2 0 120])
xlabel(slmData.H.pxxPlot,'Frequency (Hz)');
ylabel(slmData.H.pxxPlot,'Magnitude (dB)');

if any(abs(slmData.data)>.95)
    set(slmData.H.dBText,'foregroundcolor',[1 0 0]);
elseif any(abs(slmData.data)>.8)
    set(slmData.H.dBText,'foregroundcolor',[1 1 0]);
else
    set(slmData.H.dBText,'foregroundcolor',[0 0 0]);
end
set(slmData.H.dBText,'string',sprintf('%.0f dB',slmData.dB));

if slmData.recFlag
    set(slmData.H.recText,'foregroundcolor',[1 1 0])
    set(slmData.H.recText,'String',sprintf('%.1f secs',length(slmData.rec)/slmData.fs));
end