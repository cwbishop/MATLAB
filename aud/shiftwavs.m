%function [corrs swavs] = shiftwavs(template1,template2,testdata,maxlag) 
%A function used to correlate an output signal with the addition of two
%input waveforms at different lags
%template1 moves from left to right over stationary template2 and the 2 are added together
% maxlag is the maximum distance to move x before and after y

function [corrs swavs] = shiftwavs(template1,template2,testdata,maxlag) 
x = template1(:);
y = template2(:);
z = testdata(:);
output = zeros(length(x),maxlag*2+1);
ypad = [zeros(maxlag,1); y; zeros(maxlag,1)];
for i = 1:maxlag*2+1
swavs(:,i) = x + ypad(i:length(x)+i-1);
corrs(i) = corr(z,swavs(:,i)); 
end