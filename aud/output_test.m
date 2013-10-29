function calData=output_cal(outName,inName,testSnd,desc,fs,nsteps,stepSize)

if ~exist('desc','var') || isempty(desc)
    desc='';
end
if ~exist('fs','var') || isempty(fs)
    fs=48000;
end
if ~exist('nsteps','var') || isempty(nsteps)
    nsteps=10;
end
if ~exist('stepSize','var') || isempty(stepSize)
    stepSize=20*log10(.5); %default is to halve amplitude each step
end

if isnumeric(testSnd)
    testSnd={testSnd};
end

date=datestr(now);

caldB=str2double(inputdlg('First we will record a calibration tone. Please input the dB of the calibration tone'));
done=0;
while ~done
    fprintf(1,'When the calibration tone is playing, press return to record for 3 seconds.\n')
    pause();
    fprintf(1,'Recording....\n');
    
    calRec=rec_time(3,fs);
    
    calAmp=max(abs(calRec));
    
    if calAmp > .6 || calAmp < .3
        fprintf(1,'WARNING: Calibration amplitude of %g. This value should be between .3 and .6.\n\n',calAmp);
    else
        done = 1;
    end
end

fprintf(1,'Great, now connect the output to be calibrated with the recording device and press enter.\n')
pause();

calData.outName=outName;
calData.inName=inName;
calData.desc=desc;
calData.date=date;
calData.fs=fs;
calData.caldB=caldB;
calData.calRec=calRec;

for s=1:length(testSnd)
    if ischar(testSnd{s})
        fprintf(1,'\nUsing Test Sound: %s\n',testSnd{s});
        [testSnd{s},tempFs]=wavread(testSnd{s});
        if tempFs ~= fs
            testSnd{s}=resample(testSnd{s},fs,tempFs);
        end
    else
        fprintf(1,'\nUsing Vector Test Sound\n');
    end

    calData.testSnd{s}=testSnd{s};

    %preallocated for speed
    testAmp=zeros(1,nsteps);
    testRecs=repmat(nan,[length(testSnd{s}) nsteps]);

    for i=1:nsteps
        testAmp(i)=max(max(abs(testSnd{s})));
        fprintf(1,'Recording test with amplitude of %g ...\n',testAmp(i));
        testRecs(:,i)=rec_vec(testSnd{s},fs);

        if max(abs(testRecs(:,i))) > .9
            fprintf(1,'WARNING: test recording may be clipping!\n');
        else

        end

        testSnd{s}=testSnd{s}.*10^(-abs(stepSize)/20); %reduce output by stepSize in dB each step, also make sure we don't get confused by negative or positive steps
    end

    calData.testAmp{s}=testAmp;
    calData.testRecs{s}=testRecs;
end

