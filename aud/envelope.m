function [gap] = envelope(file)
%Figures out the temporal envelope of a single word sound file, returns the
%gaps in the sound. each row is a different gap, the 1st collum is the
%starting sample, the second collum is the ending sample


gap=[];
gapCount = 1;
gapFlag = 0;
[tempWav sampr] = wavread(file);
    
y = abs(hilbert(tempWav));
tempenv = bandpass(y, 0.0001, 40, 0, 1/sampr);
shift = length(tempWav)-length(tempenv);
    
if shift > 0
    tempenv = tempenv(floor(shift/2):length(tempenv)-ceil(shift/2));
end;
    
tempenv = tempenv / max(tempenv); %normalization to 1
figure,plot(tempenv);
    
word = ones(length(tempenv),1);
for j=1:length(tempenv)
    if tempenv(j) < .05 && ~gapFlag
        gap(gapCount,1) = j;
        gapFlag = 1;
    end
    if tempenv(j) > .05 && gapFlag
        gap(gapCount,2) = j;
        gapFlag = 0;
        gapCount = gapCount+1;
    end
end;