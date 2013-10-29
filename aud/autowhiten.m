function [y,Hdw,Py,fy]=autowhiten(x,Fs,Nfilt,oct,smin)
% AUTO WHITEN   
%           Automatically whitens an input signal.  Uses filtfilt to preserve
%           phase spectrum.  Calls logsmooth for smoothing anisotropically
%           in log-frequency.
% INPUTS    
%   x       input (non-white) signal
%   Fs      sampling frequency for x
%   Nfilt   length of whitening filter.  This
%           will determine how closely your filter approximates the
%           smoothed autowhitening spectrum.
%   oct     width, in octaves, of the smoothing kernel, subject to smin.
%            Default = 1/10
%   smin    minimum number of points to include in a kernel, must be odd.
%           Larger numbers keep signal smoother at very low frequencies.
%               Default = 101
%
% OUTPUTS
%   y       whitened signal
%   Hdw     whitening filter for filtfilt (corrects only half the
%           deviations!)
%   Py      power spectrum of whitened signal
%   fy      frequency array for plotting Py
%
%           [y,Hdw,Py,fy]=autowhiten(x,Fs,Nfilt,oct,smin)
%
% MillerLM 01/07

% Hard-coded defaults
Fmin = 20;  % minimum frequency for logarithmic spacing, in Hz

% Input checks
if nargin < 5
    smin = 9;
end
if nargin < 4
    oct = 1/10;
end


%% Example inputs
% Fs = 48000;
% Nfilt = 900;
% Nsm = 300;
% oct = 1/10;
% smin = 101;

%%  initialize variables for sgolay smoothing
%  smth = .0107; %smoothing as proportion of Fs
%  span = round(smth*Fs/2)*2 + 1; %span for sgolay smoothing, must be odd

% % Make a nonwhite noise sample
% wntmp = rand(1,10*Fs);
% wn = wntmp-mean(wntmp);
% Ntmp = 1000;
% n = 0:1/3:9.67;
% Flow = 20;
% F = [0 Flow*2.^n Fs]/Fs;  %could use logspace() here
% A = 10.^([0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 6 10 6 3 0 0 0 -3 -6 -6 -3 0 0 -6 -12]/20);
% dnw = fdesign.arbmag('N,F,A',Ntmp,F,A);
% Hdnw = design(dnw,'freqsamp');
% %hnw = fvtool(Hdnw,'MagnitudeDisplay','Zero-phase','DesignMask','on');
% %set(hnw,'Fs',Fs), set(gcf,'Color','white'), set(gca,'Xscale','Log')
% nwn = filter(Hdnw.Numerator,1,wn);
% 
% x = nwn;
% % 
% 
% Plot input spectrum
[Pxx,fxx] = pwelch(x,[],[],[],Fs);
PdB = 10*log10(Pxx);
h1=figure;, plot(fxx,PdB), title('Auto-whitening')
set(gca,'Xscale','Log')

% initial sgolay smooth the power spectrum
% PdBsm = smooth(PdB,span,'sgolay',2);
% figure(h1), hold on, plot(fxx,PdBsm,'r');

% downsample and smooth  with anisotropic, log kernel
[Poctsm,foctsm] = logsmooth(Pxx,fxx,oct,smin);
PoctsmdB = 10*log10(Poctsm);
figure(h1), hold on, plot(foctsm,PoctsmdB,'g')

% interpolate smoothed spectrum to order N
intfxx = [0 logspace(log10(Fmin),log10(fxx(end)),Nfilt)];
PdBint = interp1(foctsm,PoctsmdB,intfxx,'spline');
figure(h1), hold on, plot(intfxx,PdBint,'ko')

% invert about the mean and halve the deviations for filtfilt
PdBinv = (mean(PdBint)-PdBint)./2;
Pinv = 10.^(PdBinv/20);
figure(h1), hold on, plot(intfxx,(PdBinv + mean(PdBint)),'r')
legend('original','smoothed','interpolated','half-inverted')

% Filter to whiten
F = intfxx./(Fs/2);  %normalize frequencies to nyquist
F(end)=1;
dw = fdesign.arbmag('N,F,A',Nfilt,F,Pinv);
Hdw = design(dw,'freqsamp');
hw = fvtool(Hdw,'MagnitudeDisplay','Zero-phase','DesignMask','on');
set(hw,'Fs',Fs), set(gcf,'Color','white'), set(gca,'Xscale','Log')
y = filtfilt(Hdw.Numerator,1,x); % use filtfilt and preserve phase
% N.B.  from filtfilt help:  "For best results, make sure the sequence you are filtering has length
%   at least three times the filter order and tapers to zero on both edges."
% 
figure, hold on
[Py,fy] = pwelch(y,[],[],[],Fs);
PdBy = 10*log10(Py);
plot(fy,PdB), set(gca,'xscale','log')
plot(fy,PdBy,'r'), set(gca,'xscale','log'), title('Original vs Whitened')
legend('original','whitened')
