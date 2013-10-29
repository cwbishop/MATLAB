function signal = create_PEstim(sig, lead, offset, fs, diff)
%signal = create_PEstim(sig, lead, offset, fs, diff)
%
%Takes a signal and an offset, with an optional 
%alternative frequency, and creates a stimuli to
%demonstrate the Precedence Effect with the signal
%leading on the given side.
%
%INPUTS:
%  sig    - Base signal of the stimuli
%  lead   - Channel that will lead the stimuli
%  offset - Offset in seconds between onset of the signals
%  fs     - Sampling frequency. Default is 48000.
%  diff   - Different signal to pair with the lead. Defaults to identical
%           signal

if ~exist('fs', 'var') || isempty(fs)
    fs = 48000;
end

%If the different lag signal was not set it is
%made identical to the lead.
if ~exist('diff', 'var') || isempty(diff)
    diff = sig;
end

%The signal offset is created and then applied
%to the lead and lag signal.
toffset = offset * fs;
round(toffset);
off = zeros(toffset, 1);
opp = vertcat(off, diff);
sig = vertcat(sig, off);

%The lead variable is checked and then dictates
%which signal is assigned to which channel. An error
%notification is displayed if lead is not set.
if lead == 'l' || lead == 'L'
     signal(:, 1) = sig;
     signal(:, 2) = opp;
else
    if lead == 'r' || lead == 'R'
        signal(:, 2) = sig;
        signal(:, 1) = opp;
    else
        disp('Error: Function call requiers a lead (L/R).');
    end
end

        
    

    