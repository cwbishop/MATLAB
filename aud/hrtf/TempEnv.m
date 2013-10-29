function [S] = TempEnv(wav, win)
% DESCRIPTION:
%   Extract the temporal envelope of speech.  Temporal envelope is
%   estimated by computing the RMS of a sliding window over the length
%   of the waveform.  The RMS is then averaged to further remove high 
%   frequency modulations
%
% INPUT:
%   P:      string, wav filenames
%   win:    double, size of sampling window (sec)
%
% OUTPUT:
%   S:      Struct, sentence characteristics with fields
%               fn:     filename
%               
%   win:    double, sampling window used (if sampling window not even)
%
% Bishop, Chris Miller Lab July 2006

% for pn=1:length(P(:,1))
    
    % Read in the wavefile and get the sampling rate.
%     [wav, fs] = wavread(P(pn,:));
fs=96000;
    % Estimate the number of sampes in sampling window
    win = round(win*fs);

    % Pad wav array so we can fully sample the entire waveform in a uniform
    % fashion
    origwav = wav;
    padwav = [zeros(win,1); wav; zeros(win, 1)];

    % Solve for Temporal Envelope
    Tenv = [];
    for i=1:size(origwav,1)
        Tenv = [Tenv; RMS(padwav(i+round(win-win/2):i+round(win+win/2)))];
    end % i=1:size(origwav,1)

    % This section Smoothes the Tenv by averaging the RMS over the same window.

    % Pad Tenv by a window on either side
    tmp = Tenv;
    tmp = [tmp; zeros(win,1)];
    tmp = [zeros(win,1); tmp];

    tmp = bandpass(tmp, 0.0001, 40, 0, 1/fs);
%     for i=1:size(Tenv,1)
%         tmp(i+win) = mean(tmp(i+round(win-win/2):i+round(win+win/2)));
%     end smoothing function
    
    mTenv = tmp(win:win+size(Tenv,1)-1);

%     % Plot it out to check the fit.
%     figure, hold on
%     Ttime = 0:1:size(origwav,1)-1;
%     Ttime = Ttime ./ fs;
% 
%     subplot(3,1,1), hold on, title('Origwav + Tenv');
%     plot(Ttime, origwav, 'b');
%     plot(Ttime, Tenv, 'r');
% 
%     subplot(3,1,2), hold on, title('Tenv + meanTenv');
%     plot(Ttime, Tenv, 'r');
%     plot(Ttime', tmp(win:win+size(Tenv,1)-1), 'g');
% 
%     subplot(3,1,3), hold on, title('Origwav + MeanTenv');
%     plot(Ttime, origwav, 'b');
%     plot(Ttime', tmp(win:win-1+size(Tenv,1)), 'g');
% 
%     S(pn).fn = P(pn,:);
%     S(pn).wav = wav;
%     S(pn).te = Tenv;
%     S(pn).mte = mTenv;
%     
%     win = win / fs;
%     
%     clear wav fs origwav padwav tmp Tenv mTenv Ttime;
    
    
    
% end % for P(:,1)

