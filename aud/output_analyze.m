function [tf pnRecdB fv]=output_analyze(calData,iPink,iSweep,plotFlag)
%analyze the output of a calData session, needs a kind of kludgy explicit
%mark of the recs that are pink noise and the recs that are sweeps.

if ~exist('plotFlag') || isempty(plotFlag)
    plotFlag=1;
end

freqRes=50;

if exist('iPink','var') && ~isempty(iPink)
    %pink noise will get us most of the important stuff, a freq response,
    %amplitude linearity
    
    %load in the standard ref because if we've filtered it (like with the
    %sensimetrics) we don't want to erase the effects of those filters by
    %looking at rec relative to output
    [ref,refFs]=wavread('bppn_48k.wav');
    ref=resample(ref,calData.fs,refFs);
    
    %transform into db space
    refPxx=db(pwelch(ref,calData.fs/freqRes,[],[],calData.fs));
    
    %for transfer function, we won't care about absolute level, just freq
    %dependence of power, so mean center
    mcrefPxx=refPxx-mean(refPxx);
    
    %get a power spectrum for each rec
    for i=1:size(calData.testRecs{iPink},2)
        [pxx(:,i),fv]=pwelch(calData.testRecs{iPink}(:,i),calData.fs/freqRes,[],[],calData.fs);
    end
    
    %transform into db space and mean center as with ref
    pxx=db(pxx);
    mcpxx=pxx-repmat(mean(pxx),[size(pxx,1) 1]);
    
    %transfunction is simply subtraction of refPxx in dB space
    tf=mcpxx-repmat(mcrefPxx,[1,size(mcpxx,2)]);
    
    %kludgy way to get rid of dc
    tf(1,:)=0;
    
    pnRecdB=calData.caldB+(db(rms(calData.testRecs{iPink})/rms(calData.calRec)));
    
    if plotFlag
        figure,plot(fv,mean(tf,2))
        set(gca,'xscale','log')
        axis([100 16000 min(mean(tf,2))*1.2 max(mean(tf,2))*1.2])
        xlabel('Frequency (Hz)')
        ylabel('Distortion (dB)');
        title(sprintf('Average Transfer Function: Out - %s, In - %s',calData.outName,calData.inName));


        figure,imagesc(pnRecdB,fv,tf)
        set(gca,'ydir','norm')
        set(gca,'ylim',[100 16000])
        xlabel('Level (dB)');
        ylabel('Frequency (Hz)');
        title(sprintf('Transfer Function by Level: Out - %s, In - %s',calData.outName,calData.inName));
        
        pnOutdB=db(calData.testAmp{iPink}./max(calData.testAmp{iPink}));
        ideal=[min(min(pnOutdB),min(pnRecdB)):0];
        figure,plot(ideal,ideal,'k'),hold on,plot(pnOutdB,pnRecdB-max(pnRecdB))
        xlabel('Difference from max OUTPUT (dB)')
        ylabel('Difference from max RECORDING (dB)')
        title(sprintf('Linearity of Loudness: Out - %s, In - %s',calData.outName,calData.inName));
        axis image
    end
end

if exist('iSweep','var') && ~isempty(iSweep)
    %we mainly want sweeps to determine harmonic distortions. this probably
    %could be improved by using something like wavelet analysis to resolve 
    %both low and high freq well. Also, right now we just check for the
    %distortion at max rec, but it would ne nice to look at level
    %dependence
    
    [s,f,t]=(spectrogram(calData.testRecs{iSweep}(:,1),calData.fs/freqRes,[],[],calData.fs));
    s=db(s);
    
    %find the freq bin with the max dB for each time point
    [m,i]=max(s);
    
    %get the freq in hz
    ff=f(i);
    
    %get the index of the freq bin of the first harmonic
    ih=i.*2-1;
    
    %for each time point, find the db difference between the fundamental
    %and it's first harmonic
    for it=1:size(s,2)
        if ih(it)<=size(s,1) %only bother to try if we have data for that freq
            fd(it)=s(ih(it),it)-s(i(it),it);
        end
    end
    
    if plotFlag
        figure,plot(ff(1:length(fd)),fd,'.')
        xlabel('Frequency (Hz)')
        ylabel('Relative size of first harmonic (dB)')
        title(sprintf('Harmonic distortions at max rec output: Out - %s, In - %s',calData.outName,calData.inName));
    end
end