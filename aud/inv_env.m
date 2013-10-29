function [wave,AM] = inv_env(sig, top)
%
%
%
%

sig = un_tone_shape(.025,[],.1,48000,sig);
sig(1) = 0;
env = elope(sig, 0, 20000, 0, top, 48000);
env(1:240) = env(241);
env(4560:end) = env(4560);
nenv = 1 ./ env;
nsig = sig .* nenv;
nsig = nsig ./ max(nsig);

envel = elope(nsig, 0, 20000, 0, 50, 48000);
clip = envel(720:4080);
AM = max(abs((clip - mean(clip))/mean(clip)));

wave = tone_shape(.025,[],.1,48000,nsig);