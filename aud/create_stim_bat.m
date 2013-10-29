function create_stim_bat(freq1, freq2)
%
%
%
%

warning off all

rand('twister',sum(100*clock));
inc = 1;
good = 0;
storage = zeros(100,2,4801);
varst1 = zeros(1000,3);
varst2 = zeros(1000,3);
best1 = 1;
best2 = 1;
file = load(sprintf('48000k Octave WN Filters.mat'));
filter1 = file.(sprintf('F%d_0', freq1));
filter2 = file.(sprintf('F%d_0', freq2));
variance_curve = 0;
while inc <= 1

c = 1;
x = 0;
y = 1;


while good == 0
failsafe = 0;    
while x == 1 || y == 1
noise1 = rand(48000,1);
noise1 = noise1 .* 2;
noise1 = noise1 - mean(noise1); 
noise1 = noise1 ./ (max(abs(noise1))*2);



psig1 = filter(filter1, noise1);
psig1 = fliplr(psig1);
psig1 = filter(filter1, psig1);
psig1 = fliplr(psig1);


%psig1 = fftfilt(filter,noise1);
if freq1 == 100
    w = 6000;
else
    w = 0;
end

sig1 = psig1(8000 + w: 12800 + w);


sig1 = tone_shape(.025,[],.1,48000,sig1);

env1 = elope(sig1, 0, 5000, 0, 50, 48000);

% disp((max(env1) - mean(env1(1200 : 3600))) / mean(env1(1200 : 3600)));
% disp((mean(env1(1200 : 3600)) - min(env1(1200 : 3600))) / mean(env1(1200 : 3600)));

if (max(env1) - mean(env1(1200 : 3600))) / mean(env1(1200 : 3600)) < .05 
    if (mean(env1(1200 : 3600)) - min(env1(1200 : 3600))) / mean(env1(1200 : 3600)) < .05
        y = 0;
    end
else
    y = 1;
end
clip = env1(1200:3600);
if max(abs((clip - mean(clip)) / mean(clip))) < best1
    best1 = max(abs((clip - mean(clip)) / mean(clip)));
    disp(sprintf('Best of Signal 1 = %0.3f',best1));
end

if variance_curve(1) == 0
    variance_curve = max(abs((clip - mean(clip)) / mean(clip)));
else
    variance_curve = horzcat(variance_curve, max(abs((clip - mean(clip)) / mean(clip))));
end
if length(variance_curve) > 155e6
    save('variance_curve.mat','variance_curve');
    variance_curve = 0;
end
if mod(length(variance_curve), 10000) == 0
    disp('!')
end

end

x = 0;
y = 1;

while (c > .1 || c < 0 || x == 1 || y == 1) && failsafe < 10000 
 
if failsafe == 0
    disp ('Sig 2 Gen')
end

noise2 = rand(48000,1);
noise2 = noise2 .* 2;
noise2 = noise2 - mean(noise2); 
noise2 = noise2 ./ (max(abs(noise2))*2);


psig2 = filter(filter2, noise2);
psig2 = fliplr(psig2);
psig2 = filter(filter2, psig2);
psig2 = fliplr(psig2);


%psig2 = fftfilt(filter2,noise2);

if freq2 == 100
    w = 6000;
else
    w = 0;
end


sig2 = psig2(8000 + w: 12800 + w);

sig2 = tone_shape(.025,[],.1,48000,sig2);

c = corr(sig1, sig2);
%t = xcorr(sig1, sig2);

%if (max(t) > 160)
%    x = 1;
%else
%    x = 0;
%end

env2 = elope(sig2, 0, 5000, 0, 50, 48000);
if (max(env2) - mean(env2(1200 : 3600))) / mean(env2(1200 : 3600)) < .05 
    if (mean(env2(1200 : 3600)) - min(env2(1200 : 3600))) / mean(env2(1200 : 3600)) < .05
        y = 0;
    end
else
    y = 1;

end


clip = env2(1200:3600);
if max(abs((clip - mean(clip)) / mean(clip))) < best2
    best2 = max(abs((clip - mean(clip)) / mean(clip)));
    disp(sprintf('Best of Signal 2 = %0.3f',best2));
end
variance_curve = horzcat(variance_curve, max(abs((clip - mean(clip)) / mean(clip))));
if length(variance_curve) > 155e6
    save('variance_curve.mat','variance_curve');
    variance_curve = 0;
end
if mod(length(variance_curve), 10000) == 0
    disp('!')
end

if y == 0 && c < .1 && c > 0
    good = 1;
else
    failsafe = failsafe + 1;

end

end
if good == 0
    disp ('Sig 1 Gen')
end

end

storage(inc, 1, :) = sig1;
storage(inc, 2, :) = sig2;

varst1(inc, 1) = max(env1) - mean(env1(1200 : 3600));
varst1(inc, 2) = mean(env1);
varst1(inc, 3) = mean(env1(1200 : 3600)) - min(env1(1200 : 3600));

varst2(inc, 1) = max(env2) - mean(env2(1200 : 3600));
varst2(inc, 2) = mean(env2);
varst2(inc, 3) = mean(env2(1200 : 3600)) - min(env2(1200 : 3600));

good = 0;

inc = inc + 1;
disp(inc);

end

save('C:\Documents and Settings\slondon\My Documents\MATLAB\new 200hz test bat.mat', 'storage', 'varst1', 'varst2');
