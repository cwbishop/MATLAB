%Normalization of Harard Corpus percieved loudness for all modified pitches

fs = 22050; %sampling frequency

[a1,b1,a2,b2]=equalloudfilt(fs); %provides filter coeficents for a equal loudness filter and a 150hz high pass to simulate percieved loudness.

%create string ID for all pitches used
semitoneVec=[-1200:25:1200];
for i=1:length(semitoneVec)
    if semitoneVec(i) < 0
        
        semitoneID{i}='m';
    else
        semitoneID{i}='p';
    end
    if abs(semitoneVec(i)) < 100
        semitoneID{i}=[semitoneID{i} '0'];
    end
    if semitoneVec(i) == 0
        semitoneID{i}=[semitoneID{i} '0'];
    end
    semitoneID{i}=[semitoneID{i} num2str(abs(semitoneVec(i)))];
end

for p=1:length(semitoneVec)
    for s=1:720 % number of sound file to normalize
        sent = wavread(['C:\Documents and Settings\khill\My Documents\Experiments\MSAAT\stimuli\str_' semitoneID{p} '\AW' num2str(s) 'str_' semitoneID{p}]); % sound file path
        fileMax(s,p)=max(abs(sent));
        percLoud(s,p)=rms(filter(b1,a1,filter(b2,a2,sent))); %apply both filter coefficients and take the rms
    end
    disp([semitoneID{p} 's read']);
end

% obtain normalization values
for p=1:length(semitoneVec)
    for s=1:720
        normV(s,p)=mean(mean(percLoud))/percLoud(s,p); 
    end
end

resMax=normV.*fileMax;
clipScale=.9/max(max(resMax));
normV=normV.*clipScale;

disp('Beginning normalization');
pause();

% normalize RMS values and write the files
for p=1:length(semitoneVec)
    for s=1:720
        sent = wavread(['C:\Documents and Settings\khill\My Documents\Experiments\MSAAT\stimuli\str_' semitoneID{p} '\AW' num2str(s) 'str_' semitoneID{p}]); % sound file path
        sent = sent*normV(s,p);
        targ = ['C:\Documents and Settings\khill\My Documents\Experiments\MSAAT\stimuli\EL_norm\str_' semitoneID{p} '\'];
        if ~exist(targ)
            mkdir(targ);
        end
        wavwrite (sent,fs,[targ 'AW' num2str(s) 'str_' semitoneID{p}]);
    end
    disp([semitoneID{p} 's normalized']);
end