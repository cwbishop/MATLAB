function rec=rec_tones(hz,amp,t,fs,dir,tag)

%var defaults
if ~exist('amp','var')||isempty(amp)
    amp=1;
end
if ~exist('t','var')||isempty(t)
    t=1;
end
if ~exist('fs','var')||isempty(fs)
    fs=44100;
end
if ~exist('dir','var')||isempty(dir)
    dir=pwd;
end
if ~exist('tag','var')||isempty(tag)
    tag='';
else
    tag=['-' tag];
end

fadeVec=[linspace(0,1,round(fs*.01))';ones(fs*(t-.02),1);linspace(1,0,round(fs*.01))'];

for i=1:length(hz)
    for a=1:length(amp);
        outp=sin_gen(hz(i),t,fs);
        outp=outp.*fadeVec*amp(a);
        rec=rec_vec(outp,fs);
        wavwrite(rec,fs,sprintf('%s-%d-%g%s.wav',date,hz(i),amp(a),tag));
        pause(1);
    end
end