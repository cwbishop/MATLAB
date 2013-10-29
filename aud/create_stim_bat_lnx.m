function create_stim_bat_lnx(freq)
%
%
%
%

% [error, ID] = unix('echo $JOB_ID'); 
% name_ID = ID(1:end-1);

warning off all

rand('twister',sum(100*clock));

file = load(sprintf('48000k 2 Octave WN Filters.mat'));
filter1 = file.(sprintf('F%d_0', freq));
storage = zeros(1000,4801);
AM_activity = zeros(1000,1);
inc = 1;

while inc < 10000
y = 1;

while y == 1
noise = rand(48000,1);
noise = noise .* 2;
noise = noise - mean(noise); 
noise = noise ./ (max(abs(noise))*2);



psig = sosfilt(filter1, noise);
psig = fliplr(psig);
psig = sosfilt(filter1, psig);
psig = fliplr(psig);


if freq == 100
    w = 6000;
else
    w = 0;
end

sig = psig(8000 + w: 12800 + w);


sig = tone_shape(.025,[],.1,48000,sig);

env = elope(sig, 0, 5000, 0, 50, 48000);

clip = env(1200:3600);
var = max(abs((clip - mean(clip))/mean(clip)));
AM_activity(inc) = var;
if var < .15
    y = 0;
end

end

storage(inc, :) = sig;
disp(inc)
inc = inc + 1;
fname = sprintf('C:\\Documents and Settings\\slondon\\My Documents\\MATLAB\\%dhz test stim bat.mat', freq);
save(fname, 'storage', 'AM_activity');

end


