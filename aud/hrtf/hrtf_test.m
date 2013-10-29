function test=hrtf_test(sub)


if ischar(sub)
    expPath = 'C:\Documents and Settings\khill\My Documents\Experiments\hrtfs\';
    subPath = [expPath sub '\'];


    load([subPath sub '-hds'])
else
    hds=sub;
end

fs=hds.fs;

load('bppn_3sec')
[sent,sampr]=wavread('AW1str_p000.wav');
sent=resample(sent,fs,sampr);

nlocs=size(hds.hrir,3);
nchans = 2;

for loc=1:nlocs
    for ch=1:nchans
        test(:,ch,loc)=fftfilt(hds.hrir(:,ch,loc),bppn(1:fs));
    end
    test(:,:,loc)=test(:,:,loc)./max(max(test(:,:,loc)));
end

for i=1:nlocs, wavplay(test(:,:,i),fs),pause(.3),end