function audiometry_print(tv,f,figTitle)

[tv,f]=audiometry_conv(tv,f);

figure
plot(tv)
set(gca,'XTickLabel',f);
xlabel('Frequency (Hz)');
ylabel('Detection Threshold (dB)');
legend('Left','Right');

if exist('figTitle'), title(['Audiometry: ' figTitle]); end