function C = filterC(f,plotFilter)

% FILTERC Generates an A-weighting filter.
%    FILTERC Uses a closed-form expression to generate
%    an A-weighting filter for arbitary frequencies.
%
% Author: Douglas R. Lanman, 11/21/05
%  Edit jk 8/11/09
% Define filter coefficients.
% See: http://www.beis.de/Elektronik/AudioMeasure/
% WeightingFilters.html#A-Weighting

%c1 = 3.5041384e16;
c1 = 12194^2^2;
c2 = 20.598997^2;
c3 = 12194.217^2;

% Evaluate C-weighting filter.
f(find(f == 0)) = 1e-17;
f = f.^2; num = c1*f.^2;
den = ((c2+f).^2).* ((c3+f).^2);
C = num./den;

% Plot A-weighting filter (if enabled).
if exist('plotFilter') & plotFilter
    
   % Plot using dB scale.
   figure(2); clf;
   semilogx(sqrt(f),10*log10(C));
   title('C-weighting Filter');
   xlabel('Frequency (Hz)');
   ylabel('Magnitude (dB)');
   xlim([10 100e3]); grid on;
   ylim([-70 10]);
   
   % Plot using linear scale.
   figure(3); plot(sqrt(f),C);
   title('C-weighting Filter');
   xlabel('Frequency (Hz)');
   ylabel('Amplitude');
   xlim([0 44.1e3/2]); grid on;

end