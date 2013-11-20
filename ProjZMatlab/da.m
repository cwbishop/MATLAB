addpath c:\APE

% make a figure
myFig = figure('position',[1100 800 150 150]);

p = presenter
p = add_device(p,'RP2','USB','LoopPlayback.rcx',50000);
p = set_tag_val(p,'WavData',zeros(1,100000)); % zero out the 2 second buffer

% the variables that matter to us (people) are:
stimType = 'da'
stimDuration = 100; % microseconds
% stimRate = 51.1; % Hz
stimRate = 11.1; % Hz
numSweeps = 2000; % repeat this many times

% the variables that matter to the TDT:
samplingRate = get(p,'samprate');
repeatTime = 1/stimRate; % period in seconds
repeatTime_samples = ceil(repeatTime * samplingRate); % period in samples
WavSize = repeatTime_samples;
WavData = zeros(1,length(WavSize));

% the idea:
% 1. Generate a signal or load one from disk

stimDur_samples = ceil((stimDuration / 1000000) * samplingRate);
if stimDur_samples ~= 0
    warning(sprintf('Stim duration is %d samples (= %.2f us)',...
        stimDur_samples,stimDur_samples*(1000000/samplingRate)));
end

% Here are some ways to control the stimulus intensity. Add or subtract a
% few dB by changing these: 
add_dB_to_Click = 0; % dB
add_dB_to_Noise = 10; % dB
add_dB_to_Da = 0; % dB

% here, we compute the scalar (multiplier) that corresponds to the
% requested dB change. Take note that we don't ever want to put numbers
% into the TDT that are greater than +/- 10 (volts).

amplifyClick = 10^(add_dB_to_Click/20);  % 20 dB = 10x gain; 6 dB = 2x, etc
amplifyNoise = 10^(add_dB_to_Noise/20);  %
amplifyDa = 10^(add_dB_to_Da/20);  % 

switch stimType
    case 'click'
%         myWav = [ones(1,stimDur_samples) zeros(1,WavSize-stimDur_samples)];
          myWav = ones(1,stimDur_samples).*amplifyClick;
    case 'noise'
        myWav = randn(1,stimDur_samples).*amplifyNoise;
    case 'da'
        myWav = wavread('da_40.wav')'.*amplifyDa;
    otherwise
        error('I do not know how to make that sound.');
end

% 1b. make sure it's long enough. 
if length(myWav) > WavSize
    error('Stimulus duration is longer than repeat time.');
else
    myWav = [myWav zeros(1,WavSize-length(myWav))];
end

% 2. Set the TDT parameters and upload the signal to the RP2. 

p = set_tag_val(p,'WavSize',WavSize);
p = set_tag_val(p,'WavData',myWav);

% 2b. Set up a gui

% already made a figure


% make an 'edit' uicontrol to show the sweeps
sweepsDisplay = uicontrol('style','edit','string', sprintf('sweeps'),'units','normalized','position',[.2 .6 .6 .3]);

% make a 'pushbutton' uicontrol with callback to halt
foo = uicontrol('string','halt','callback','set(myFig,''userdata'',1)','units','normalized','position',[.2 .2 .6 .3]);

% 3. Start the TDT running. Keep track of how many times it has played.
p = set_tag_val(p,'RunStop',0); % stop it
p = set_tag_val(p,'ResetCounter',1); % queue up the track
p = set_tag_val(p,'ResetCounter',0); 
p = set_tag_val(p,'RunStop',1); % drop the beat

% now loop forever...
done = 0; 
set(myFig,'userdata',0); % not done yet...

while ~done
% check the counter
 newCount = get_tag_val(p,'Counter');
 
 % if it's too old, stop
 if (newCount > numSweeps) | get(gcf,'userdata')==1
     halt_TDT(p);
     fprintf('all done\n');
     return;
 end
 
%      fprintf('%d sweeps\n',newCount);
     set(sweepsDisplay,'string',sprintf('%d sweeps',newCount));
     drawnow;
 
 pause(0.5);
end

% 4. Stop when done. 





