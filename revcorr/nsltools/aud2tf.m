function [rtf, stf] = aud2tf(y, rv, sv, STF, SRF, BP)
% AUD2TF Temporal or spatial filtering of an auditory spectrogram
%   [rtf, stf] = aud2tf(y, rv, sv, STF, SRF, BP);
%	y   : auditory spectrogram, N-by-M, where
%		N = # of samples, M = # of channels
%	stf : scale-time-frequency matrix, S-by-N-by-M, where 
%		S = # of scale
%	rtf : rate(up,down)-time-frequency matrix, 2R-by-N-by-M, where 
%		R = # of rate
%	rv  : rate vector in Hz, e.g., 2.^(1:.5:5).
%	sv  : scale vector in cyc/oct, e.g., 2.^(-2:.5:3).
%	STF	: sample temporal frequency, e.g., 125 Hz for 8 ms
%	SRF	: sample ripple frequency, e.g., 24 ch/oct or 20 ch/oct
%	BP	: pure bandpass indicator, default : 1
%
%   AUD2TF generate various spectrograms out of different temporal or
%	spatial filters with respect to the auditory spectrogram Y
%	which was generated by WAV2AUD. RTF, STF can be viewed by 
%	AUD_PLOT. RV (SV) is the characteristic frequency vector.
%	See also: WAV2AUD, RST_VIEW, COR2RST

% Auther: Taishih Chi (tschi@isr.umd.edu), NSL, UMD
% v1.00: 17-Dec-01

if nargin < 5, SRF = 24; end;
if nargin < 6, BP = 1; end;


% mean removal (for test only)
%meany   = mean(mean(y));
%y	   = y - meany;

% dimensions
K1 	= length(rv);	% # of rate channel
K2	= length(sv);	% # of scale channel
[N, M]	= size(y);	% dimensions of auditory spectrogram

% spatial, temporal zeros padding 
N1 = 2^nextpow2(N);	N2 = N1*2;
M1 = 2^nextpow2(M);	M2 = M1*2;


% calculate stf (perform aud2cors frame-by-frame) 
if K2 > 0
	stf = zeros(K2, N, M);		% memory allocation
	for i = 1:N
		stf(:, i, :) = conj(aud2cors(y(i, :), sv, SRF, 0, BP)');
	end
else
	stf = y;
end

% calculate rtf (perform filtering channel-by-channel)
% compute rate filters
HR = zeros(2*N1, 2*K1);
for k = 1:K1
    Hr = gen_cort(rv(k), N1, STF, [k+BP K1+BP*2]);
    Hr = [Hr; zeros(N1, 1)];	% SSB -> DSB
    HR(:, k+K1) = Hr;		% downward
    HR(:, k) = [Hr(1); conj(flipud(Hr(2:N2)))];	% upward
    HR(N1+1, k) = abs(HR(N1+2, k));
end

if K1 > 0
	rtf = zeros(2*K1, N, M);		% memory allocation
	for i = 1:M
		ypad = y(N, i) + (1:(N2-N))/(N2-N+1) * (y(1, i) - y(N, i));
		ytmp = [y(:, i); ypad(:)];
		YTMP = fft(ytmp(:), N2);
		% temporal filtering
		for k = 1: 2*K1
		    R1 = ifft(HR(:, k).*YTMP, N2);
		    rtf(k, :, i) = R1(1:N);
		end
	end
   %if isreal(y);
   %   rtf = real(rtf);
   %end   
else
	rtf = y;
end