function battery = create_hzBattery(base, step, semi, wide, out, omni, path, rampt, dur, lead, PEoff, Toff, jmp, fs)
%battery = create_hzBattery(base, step, wide, out, omni, path, rampt, dur,
%lead, PEoff, Toff, jmp, fs)
%
%Generates a battery of tone train stimuli of varied frequencies adhering
%to the base, step, and range of hz provided. The resulting train stimuli
%are then output as either a multi-dimensional array or as a series of wav
%files output to a specified directory.
%
%INPUTS:
%  base  - Base frequency of the battery
%  step  - Frequency steps taken between trains. If not present function
%          follows semi.
%  semi  - Frequency steps in semi-tones of an octave. If step is present
%          function ignores semi.
%  wide  - Range of frequencies generated from the base
%  out   - Method of output. 'V' for variable or 'F' for wav files. Defaults
%          to 'V'.
%  omni  - Direction of the steps. 1 increments in Hz, 2 decrements in Hz,
%          and 3 is omnidirectional. Defaults to 1.
%  path  - Directory to create the wav files in. Defaults to the MATLAB
%          directory in the user's My Documents folder.
%  rampt - Ramp time in seconds for the edges of the tones used in the
%          train. Defaults to .005 seconds.
%  dur   - Duration of the tones used in the train. Defaults to .04
%          seconds.
%  lead  - Specifies lead channel in the train. Defaults to right.
%  PEoff - Offset between channels of the stimuli. Defaults to .006
%          seconds.
%  Toff  - Offset between stimuli in the train. Defaults to .02 seconds.
%  jmp   - Offset between final stimuli in train and test stimuli. Defaults
%          to 1 second.
%  fs    - Sampling frequency. Defaults to 48000.

%This is to turn off warnings that always arise from trimming 1s in
%wavwrite.
warning off all

%This stretch is a series of checks for whether optional variables 
%have been set. They are otherwise set to default. 
if ~exist('step', 'var') || isempty(step)
    step = 0;
end

if ~exist('semi', 'var') || isempty(semi)
    semi = 0;
end

if ~exist('out', 'var') || isempty(out)
    out = 'v';
end

if ~exist('omni', 'var') || isempty(omni)
    omni = 1;
end

if ~exist('path', 'var') || isempty(path)
    path = strcat('C:\Documents and Settings\', getenv('username'), '\My Documents\MATLAB\Battery\');
end

%This try - catch segment is to see whether or not the directory specified
%to save files exists. If not the directory is created.
try
    cd (path);
catch
    slash = find(path == '\');
    foldername = path(slash(length(slash) - 1) + 1 : slash(length(slash)) - 1);
    newpath = path(1 : slash(length(slash) - 1));
    cd (newpath);
    mkdir (foldername);
end

if ~exist('rampt', 'var') || isempty(rampt)
    rampt = .005;
end

if ~exist('dur', 'var') || isempty(dur)
    dur = .04;
end

if ~exist('lead', 'var') || isempty(lead)
    lead = 'R';
end

if ~exist('PEoff', 'var') || isempty(PEoff)
    PEoff = .006;
end

if ~exist('Toff', 'var') || isempty(Toff)
    Toff = .02;
end

if ~exist('jmp', 'var') || isempty(jmp)
    jmp = 1;
end

if ~exist('fs', 'var') || isempty(fs)
    fs = 48000;
end

%The original tone and base PE stimuli are generated to spec.
tone = tone_shape(rampt, base, dur, fs);
PEBase = create_PEstim(tone, lead, PEoff, fs);

%All important data indices are set.
battery = 0;
i = base;
index = 1;

%In the event the steps in Hz were provided in semi-tones, the step is
%recalculated in relation to the base frequency.
if step == 0
    step = round(((base * 2) - base) * ((1 / 12) * semi));
end

%The loop continues until the current frequency tested is out of range of
%the battery.
while (abs(base - i) <= wide)

%The test tone is generated with the alternative frequency and then the
%train is generated.
    test = tone_shape(rampt, i, dur, fs);
    PETest = create_PEstim(tone, lead, PEoff, fs, test);
    newTrain = generate_train(PEBase, 10, Toff, jmp, fs, PETest);

%The train is saved as either a variable or a file according to specification. 
%An alternative multi-dimensional array is used for omni=3 so the variable
%records the steps pair-wise.
    if out == 'v' || out == 'V'
        if omni ~= 3
            battery(index, :, :) = newTrain;
        else
            battery(index, 1, :, :) = newTrain;
        end
    end
    
%The top of the signals are shaved so as to fit the signal in a wav file.
    if out == 'f' || out == 'F'
            wavwrite(newTrain, fs, strcat(path , 'HzBattery ', num2str(base), 'Hz varies ', num2str(wide), 'Hz Step ', num2str(i), 'Hz.wav'));
    end
    
%Modifications are made to the test frequency according to step and omni.
    if omni == 1 
        i = i + step;
    end
    if omni == 2
        i = i - step;
    end
    
%In the case of omni=3 a seconds train is constructed the opposite
%direction away from the base Hz.
    if omni == 3
        if i ~= base
            temp = i - base;
            j = base - temp;
            
            if j > 0
                test = tone_shape(rampt, j, dur, fs);
                PETest = create_PEstim(tone, lead, PEoff, fs, test);
                newTrain = generate_train(PEBase, 10, Toff, jmp, fs, PETest);
           
                
                if out == 'v' || out == 'V'
                    battery(index, 2) = newTrain;
                end
    
                if out == 'f' || out == 'F'
                   wavwrite(newTrain, fs, strcat(path, 'HzBattery ', num2str(base), 'Hz varies ', num2str(wide), 'Hz Step ', num2str(j), 'Hz.wav'));
                end
            end            
        end  
        i = i + step;
    end
    index = index + 1;
end

