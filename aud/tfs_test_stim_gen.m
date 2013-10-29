function tfs_test_stim_gen(f0,delta,sig_t,int_t,ins_t)
%
%
%
%

warning off all

i = 1;
off = f0 * delta;
load('TFS Test Filter.mat')
x = rand(((int_t * 3) + (sig_t * 8) + (ins_t * 6)) * 48000, 1);
%if f0 == 150
    x = sosfilt(bandpass_f, x);
%end
%if f0 == 300
    %x = sosfilt(bandstop300, x);
%end

x = x ./ max(abs(x));
dbdrop = 10 ^ ((- 15) / 20);
x = x .* dbdrop;

H = sin_gen(f0 * 9, sig_t, 48000);
while i < 5
    H = H + sin_gen(f0 * (i + 9), sig_t, 48000);
    i = i + 1;
end
H = H ./ max(abs(H));
H = tone_shape(.02, [], .2, 48000, H);

i = 1;
I = sin_gen((f0 * 9) + off, sig_t, 48000);
while i < 5
    I = I + sin_gen(f0 * (i + 9) + off, sig_t, 48000);
    i = i + 1;
end
I = I ./ max(abs(I));
I = tone_shape(.02, [], .2, 48000, I);

HHHH = vertcat(H, zeros(ins_t * 48000,1));
HHHH = vertcat(HHHH, H);
HHHH = vertcat(HHHH, zeros(ins_t * 48000,1));
HHHH = vertcat(HHHH, H);
HHHH = vertcat(HHHH, zeros(ins_t * 48000,1));
HHHH = vertcat(HHHH, H);


HIHI = vertcat(H, zeros(ins_t * 48000,1));
HIHI = vertcat(HIHI, I);
HIHI = vertcat(HIHI, zeros(ins_t * 48000,1));
HIHI = vertcat(HIHI, H);
HIHI = vertcat(HIHI, zeros(ins_t * 48000,1));
HIHI = vertcat(HIHI, I);


testsig1 = vertcat(zeros(int_t * 48000,1),HHHH);
testsig1 = vertcat(testsig1,zeros(int_t * 48000,1));
testsig1 = vertcat(testsig1,HIHI);
testsig1 = vertcat(testsig1,zeros(int_t * 48000,1));
testsig2 = vertcat(zeros(int_t * 48000,1),HHHH);
testsig2 = vertcat(testsig2,zeros(int_t * 48000,1));
testsig2 = vertcat(testsig2,HHHH);
testsig2 = vertcat(testsig2,zeros(int_t * 48000,1));
testsig3 = vertcat(zeros(int_t * 48000,1),HIHI);
testsig3 = vertcat(testsig3,zeros(int_t * 48000,1));
testsig3 = vertcat(testsig3,HIHI);
testsig3 = vertcat(testsig3,zeros(int_t * 48000,1));
testsig4 = vertcat(zeros(int_t * 48000,1), HIHI);
testsig4 = vertcat(testsig4,zeros(int_t * 48000,1));
testsig4 = vertcat(testsig4,HHHH);
testsig4 = vertcat(testsig4,zeros(int_t * 48000,1));

test1 = testsig1 + x;
test1 = test1 ./ max(abs(test1));
out1 = sprintf('%dHz %0.3f Offset HI Test Stim.wav',f0,delta);
test2 = testsig2 + x;
test2 = test2 ./ max(abs(test2));
out2 = sprintf('%dHz %0.3f Offset HH Test Stim.wav',f0,delta);
test3 = testsig3 + x;
test3 = test3 ./ max(abs(test3));
out3 = sprintf('%dHz %0.3f Offset II Test Stim.wav',f0,delta);
test4 = testsig4 + x;
test4 = test4 ./ max(abs(test4));
out4 = sprintf('%dHz %0.3f Offset IH Test Stim.wav',f0,delta);

wavwrite(test1, 48000, out1);
wavwrite(test2, 48000, out2);
wavwrite(test3, 48000, out3);
wavwrite(test4, 48000, out4);

