function [latency peak ] = xcorrlat(vec1,vec2,fs)
%%%vec1 and vec2 are vectors of the same length
%%%fs is the sampling rate
%%%latency is the time in which vec1 preceeds vec2. If a positive value,
%%%vec 1 occurs before vec2; a negative value means vec 2 preceeds vec1. 

x = xcorr(vec1,vec2);
[peak ppoint] = max(x);
latency = ((length(x)/2)-ppoint)/fs;