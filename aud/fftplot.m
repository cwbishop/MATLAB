%fftplot(x,Fs)
%x = signal vector
%fs = sampling rate

function fftplot(x,Fs,col)

if nargin < 3
    col = 'b';
end

n = length(x);
y = fft(x)/n;
f = Fs/2*linspace(0,1,n/2+1);
power = abs(y(1:floor(n/2)+1)).^2; power=10*log10(power); 
figure, plot(f,power,col);
xlabel('Frequency (Hz)')
ylabel('Power (dB)');


