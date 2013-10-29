function phase_check(ph)
%used to check a real and imaginary phase component with flat magnitude to
%derive a IR. Useful for linear phases, which should have a pure delay IR
%without distortions or any other known phase/IR relationship.

mag=ones(size(ph,1),size(ph,2));

hrtf=mag.*cos(ph)+sqrt(-1)*mag.*sin(ph);
hrir=ifft(hrtf,'symmetric');

figure,plot(hrir)

%PHbase=(-1*(2*pi/456)).*[1:456]'-(-1*(2*pi/456));