function [EQ]=auto_eq(fs,ofname)

if ~exist('fs') || isempty(fs)
    fs=96000;
end
if ~exist('ofname') || isempty(ofname)
    ofname='auto_eq';
end

fVec=logspace(log10(50),log10(20000),27);
nsweep=302;
t=1/fs*[0:nsweep-1]';
sweep = chirp(t,min(fVec),nsweep/fs,max(fVec),'log',90);
sweep = (sweep.*trapez(length(sweep),0.02)).*.5;
pad=zeros(round(.001*fs),1);
ref = [pad;sweep;pad];

%Set up audio I/O
nrec=length(ref)+8000;
ai = analoginput('winsound');
ao = analogoutput('winsound');
set(ai,'StandardSampleRates','Off')
set(ao,'StandardSampleRates','Off')
addchannel(ai,1:2);
addchannel(ao,1:2);
set(ai,'SampleRate',fs);
set(ao,'SampleRate',fs);
set(ai,'SamplesPerTrigger',nrec)

%Loop through recordings, with a pause for MIDI control to have time to
%kick in
EQpxx=(zeros(1,length(fVec)));
for it=1:50
    
    %Set the current eq, the first time through this should be a flat EQ
    EQ=[0 0 0 0 EQpxx]';
    deq_set(EQ,ofname);
    pause(3);
    
    %Each loop has 10 reps to minimize any idiosyncratic distortion
    for rep=1:10
        putdata(ao,[ref zeros(length(ref),1)]);
        start(ai)
        start(ao)
        tempRec(:,:,rep)=getdata(ai);
        for ch=1:2
            [y,i]=max(xcorr(ref,tempRec(:,ch,rep)));
            chOffset(ch)=length(tempRec)-i;
        end
        offset=round(mean(chOffset));
        recMv(:,:,rep)=tempRec(offset:offset-1+length(ref),:,rep);
    end
    recAvg(:,:)=mean(recMv,3);
    rec=recAvg./max(max(recAvg));

    %We're just interested in the magnitude of the TF, not phase
    fftRecs=fft(rec);
    fftRef=fft(ref);
    fftRecs=fftRecs(1:end/2,:);
    fftRef=fftRef(1:end/2);
    magRec=mean(abs(fftRecs),2);
    magRef=abs(fftRef);

    F = linspace(0,fs/2,length(fftRecs))';

    magTF=(magRef./magRec);
    magTF(find(F<min(fVec)))=1;
    magTF(find(F>max(fVec)))=1;

    %Just deal with the smoothed, interpolated mag of a TF
    [pxx,fxx]=log_smooth(magTF,F,.3,1);
    EQdelta=interp1(fxx,20*log10(pxx),fVec,'spline');
    
    %Apply the new changes (mean centered) to the old eq and restart
    EQdelta=EQdelta-mean(EQdelta);
    EQpxx=EQpxx+EQdelta;
    EQpxx=round(EQpxx*2)/2;
end

EQ=[0 0 0 0 EQpxx]';
deq_set(EQ,ofname);
