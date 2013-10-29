function slm
% slm - a sound level meter that performs a basic periodogram analysis and
%       can record sounds to the base workspace.

global slmData

%% Set some default values
slmData.fs      = 48e3; % Set sampling rate (in Hz).
slmData.cal     = 119; % Set default calibration constant. This will change based on recording gain
slmData.win     = 2^15; % Set SLM window for time plot, dB calc, and periodogram in samples. Windows longer than 2^15 tend to eat the cpu
slmData.refresh = .3; %set the refresh rate for the slm in seconds. windows much shorter than .3 start causing errors because the processing for the last refresh hasn't finished
slmData.data    = zeros(slmData.win,1); %initalized empty data
slmData.recFlag = 0; %this means it will start off not recording, but rec can be activated at any time


%% Setup sound card
slmData.AI = analoginput('winsound');
stop(slmData.AI);
addchannel(slmData.AI,1:2);

% Set and check sampling rate.
set(slmData.AI,'StandardSampleRates','Off')
slmData.fs = setverify(slmData.AI,'SampleRate',slmData.fs);

% Determine FFT window size.

% Set samples per trigger.
% Note: Use closest length supported by hardware.
set(slmData.AI,'SamplesPerTrigger',slmData.win);

% Set acquisition options.
set(slmData.AI,'TriggerRepeat',inf);
set(slmData.AI,'TimerPeriod',slmData.refresh);
set(slmData.AI,'TimerFcn',@slm_update);


%% Setup figure

% Create figure window.
slmData.H.fig = figure;
set(gcf,'Name','Sound Level Meter');
set(gcf,'NumberTitle','off','MenuBar','none');
set(gcf,'DeleteFcn',@slm_close);

% Plot FFT magnitude.
slmData.H.pxxPlot=subplot(2,1,1);
title('Fourier Analysis');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 slmData.fs/2]); ylim([50 150]);
grid on;

% Plot data window.
slmData.H.timePlot=subplot(2,2,3);
title('Waveform');
xlabel('Time');
ylabel('Input Voltage');
axis([0 slmData.win -1 1]);
grid on;

% Plot current dB estimate.
slmData.H.dBText = uicontrol('Style','text',...
    'Units', 'normalized',...
    'Position',[0.5 0.3 0.4 0.15],...
    'String','0 dB','FontSize',38,'BackgroundColor',[.8 .8 .8]);

% Plot current recorded time.
slmData.H.recText = uicontrol('Style','text',...
    'Units', 'normalized',...
    'Position',[0.5 0.1 0.5 0.075],...
    'String','Not Recording','FontSize',20,'BackgroundColor',[.8 .8 .8]);

% Create start/stop pushbutton for real time processing.
slmData.H.rtButton = uicontrol('Style','pushbutton',...
    'Units', 'normalized',...
    'Position',[0.0150 0.5 0.1 0.0556],...
    'UserData',1,'String','Stop',...
    'Callback',@slm_real_time_ctrl);

% Create start/stop record pushbutton.
slmData.H.recButton = uicontrol('Style','pushbutton',...
    'Units', 'normalized',...
    'Position',[.7 0.0111 0.1 0.0556],...
    'String','Start',...
    'Callback',@slm_rec_ctrl);


%% Begin acquisition.
start(slmData.AI);


%% Small function to gracefully stop on window close
function slm_close(obj,event)
global slmData

stop(slmData.AI);
