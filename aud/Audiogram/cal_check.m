%%%My Path
addpath(genpath('C:\Documents and Settings\campbelt\My Documents\MATLAB'),'-begin')

ff_input_dev = find_dev('Fireface 800 Analog (3+4)');
display('Abbreviated Checklist (Answers should be Yes. See Audiogram Methods for detailed list.): ')
display('Did you read Audiogram Methods recently? (check this folder)')
display('Are Fireface, DEQ, and Headphone Amp and Cal Mic PreAmp turned on?')
display('Is the preamp power box plugged into Input A?')
display('Did you check the FireFace Mixer?')
display('Is the DEQ is set to BYPASS?')
display('Is the headphone you want (akg or ety) plugged in Output A?')
display('Are you wearing an anti-static shock bracelet before you touch the preamp? Seriously.')

                    
subj = input('Please enter the the subject ID. : ','s');
runs = 1;
headphone = input('akg or ety? Make sure the correct headphone jack is plugged in. : ','s');
dBVals;
if headphone == 'akg'
gold_s = akg_dBSPL(1:13);
elseif headphone == 'ety'
gold_s = ety_dBSPL(1:13);
else
    error('Unknown headphone type')
end

same_cal = input('Use existing cal_rms value? y or n. :','s');

if same_cal == 'n'
input('Place microphone in 250 Hz calibrator(set to 114db) and press button on the side of the calibrator. Press ENTER when ready.')
cal = rec_time(.5,96000,ff_input_dev);
cal_f = highpass(cal,80,96000,2);
cal_rms = rms(cal_f(:,1))
elseif same_cal == 'y'
else
    error('Choose y or n');
end

input('Place the left earphone onto the coupler. Press ENTER when ready.')
%attn = 1;
%   FBIN    =   [20 25 32 40 50 63 80 100 125 160 200 250 ...
%       315 400 500 630 800 1000 1250 1600 2000 2500 ...
%       3150 4000 5000 6300 8000 10000 12500 16000 20000];
   tone_freq    =   [125 250 500 750 1000 1500 2000 3000 4000 6000 8000 11200 16000];
%FBIN = 200;
% mic_gain = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.5 1 1 1.5 0];
tone_db = zeros(length(tone_freq),runs);

    fs = 96000; %framerate of stimulus
    stim_time = 0.2; %stimulus length in seconds
    ramp = 0.02; %linear onset/offset time
    max_amp = 1;
    
    envelope = [linspace(0,1,fs*ramp) ones(1,fs*stim_time-ramp*2*fs) linspace(1,0,fs*ramp)]';

    for i = 1:length(tone_freq)
        tone_tmp = (sin_gen(tone_freq(i),stim_time,fs).*envelope)*max_amp;
        tone{i} = [tone_tmp tone_tmp];
    end
for i = 1:runs
cnt = 1;

for hz = tone_freq;
pause(.1);  
rec_tone{cnt,i} = rec_vec([tone{cnt}],fs,ff_input_dev,0.003);
if max(abs(rec_tone{cnt,i})) >= .98
display('Warning: Recording is clipping!!! Check preamp power gain (should be 0 db)');
end
rec_tone_f{cnt,i} = highpass(rec_tone{cnt,i},80,fs,2)';
tone_db(cnt,i) = 20*log10(rms(rec_tone{cnt,i})/cal_rms)+114;
tone_db_f(cnt,i) = 20*log10(rms(rec_tone_f{cnt,i})/cal_rms)+114;
cnt = cnt + 1;
end
end


tone_db_av = mean(tone_db_f,2);
norm_tone_db_av = tone_db_av - mean(tone_db_av);
inv_tone_db = -norm_tone_db_av;

%compare to the gold standard


tone_db_dif = tone_db - gold_s';

if any(abs(tone_db_dif(1:10)) > 3)
    display('Warning: Tone difference outside of ANSI +-3 standard. See Checklist or Audiogram Methods.')
end



%save(['C:\Documents and Settings\jrkerlin\Desktop\Audiogram\cal_data\cal_' subj '_' headphone])
