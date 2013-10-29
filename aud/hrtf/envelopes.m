function [tempenv] = envelopes(tempwav, nums)



% for i=1:length(nums)
    gaps = [];
    gapCount = 1;
    gapFlag = 0;
%     [tempWav sampr] = wavread([id '0' num2str(nums(i)) 'io.wav']);
    sampr=96000;
    
    y = abs(hilbert(tempWav));
    tempenv = bandpass(y, 0.0001, 40, 0, 1/sampr);
    
        
%     shift = length(tempWav)-length(tempenv);
    
%     if shift > 0
%         tempenv = tempenv(floor(shift/2):length(tempenv)-ceil(shift/2));
%     end;
%     
%     tempenv = tempenv / max(tempenv); %normalization to 1
%     env(1:length(tempenv),i) = tempenv;
%     
%     for j=1:length(tempenv)
%         if tempenv(j) < .05
%             if ~gapFlag
%                 gaps(gapCount) = 0;
%             end;
%             gaps(gapCount) = gaps(gapCount) + 1;
%             gapFlag = 1;
%         elseif gapFlag
%             gapCount = gapCount + 1;
%             gapFlag = 0;fun
%         end;
%     end;
%     
%     endgap = gaps(gapCount);
%     
%     if endgap/sampr > 0.02
%         x = [0:pi/((.02*sampr)-1):pi];
%     else
%         x = [0:pi/(endgap-1):pi];
%     end;
%     y = [(cos(x)+1)/2]';
%     
%     tempWav = [tempWav(1:length(tempWav)-endgap); (tempWav(length(tempWav)-endgap+1:length(tempWav)-endgap+length(x)).*y)];
%     wavwrite(tempWav, sampr, [id num2str(nums(i)) '.wav']);
% end;

