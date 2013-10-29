function hzAverage = hzDiscrimination_Exam()
%hzAverage = hzDiscrimination_Exam(base, step, semi, trialn)
%
%Delivers an exam which attempts to find the point in frequency
%differentiation where the subject can only tell the difference between two
%sounds 50% of the time.
%
%INPUTS:
%  All inputs are handled by the input dialog.

warning off all

%The following segment is responsible for all inputs into the program.
prompt = {'Base Frequency:','Increments (Hz): (Leave blank if using semi-tones)','Increments (Semi-tones): (Only read if Increment (Hz) field is empty)','Duration of Sounds:','Separation of Sounds:','Number of Trials: (Respond "0" for until Exit)','Signal Ramp:','Sampling Frequency:'};
dlg_title = 'Input specifications for discrimination task. NOTE: Hz increments override semi-tones.';
num_lines = 1;
def = {'500','10','.25','.04','.005','0','.005','48000'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

base = str2double(answer{1});
step = str2double(answer{2});
semi = str2double(answer{3});
dur = str2double(answer{4});
sep = str2double(answer{5});
trialn = str2double(answer{6});
ramp = str2double(answer{7});
fs = str2double(answer{8});

if isnan(step)
    step = 0;
end
if step == 0
    step = round(((base * 2) - base) * ((1 / 12) * semi));
end

if ~exist('trialn', 'var') || isempty(trialn)
    trialn = 0;
end
if trialn ~= 0
    trialn = trialn + 1;
end


%Instantiation of all variables.
response = 'default';
index = 1;
n = 1;
ctrl = 0;
vol = .8;
curHz = base;

%Set up of exam struct.
exam(index).signal = create_HzDiff(base, base, ramp, dur, sep, fs);
exam(index).bhz = base;
exam(index).thz = base;

%Loop to set appropriate volume level.
while ctrl ~= 1
    sound(exam(index).signal * vol, fs);
    volr = questdlg('Do you want to change the volume before the start of the task?','Volume Level','Increase Volume','Decrease Volume','OK','default');
    if strcmp(volr,'OK')
        ctrl = 1;
    end
    if strcmp(volr,'Increase Volume')
        vol = vol + .05;
    end
    if strcmp(volr,'Decrease Volume')
        vol = vol - .05;
    end
end

%Loop executes until either exit is selected or trialn trials is reached
%(must be set).
while ~strcmp(response, 'Exit') && n ~= trialn
    if strcmp(response, 'Same')
        index = index + 1;
        curHz = curHz + step;
    end
    if strcmp(response, 'Different') && index ~= 1
        index = index - 1;
        curHz = curHz - step;
    end
%An attempt is made to access the next index of exam. If it has not been
%created yet the new signal is generated and then recorded before being
%played.

    try
        sound(exam(index).signal * vol, fs);
    catch
        exam(index).signal = create_HzDiff(base, curHz, ramp, dur, sep, fs);
        exam(index).bhz = base;
        exam(index).thz = curHz;
        sound(exam(index).signal * vol, fs);
    end
    response = questdlg('Were the two tones the same or different?','Frequency Exam','Same','Different','Exit','default');
    n = n + 1;
end

%Outputs and returns.
msgbox(sprintf('Your threshold for differentiating two tones was %.5g Hz from a base of %.5g Hz or %.3g semi-tones.', exam(index).thz, exam(index).bhz,((step / (base / 12)) * (index - 1))),'Results:');

hzAverage = exam(index).thz;