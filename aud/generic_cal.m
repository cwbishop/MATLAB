%%%Miller Lab Calibration and dB Volume Determination
%%%Determine the DB values of any sound file based on RMS and peak
%function generic_cal(wavfolder,wavfilename)

%%%Change these to fit your stimulus
wavfolder = 'C:\Documents and Settings\jrkerlin\Desktop\HISA\Standardized\'
wavfilename = 'Track24Babble';
%%%%


addpath(genpath('C:\Documents and Settings\jrkerlin\My Documents\code\'))
ff_input_dev = find_dev('Fireface 800 Analog (3+4)  ');

%wavfilename = 'C:\Documents and Settings\kcbacker\My Documents\Experiments\ESPE\FIFTY_DESIGN\subjects\s0926\Lhrtf_bisc_0.wav';
display('Abbreviated Checklist (Answers should be Yes. See Audiogram Methods for detailed list.): ')
display('Are Fireface, DEQ, and Headphone Amp and Cal Mic PreAmp turned on?')
display('Is the preamp power box plugged into Input A?')
display('Did you check the FireFace Mixer?')
display('Is the DEQ is set to BYPASS?')
display('Is the headphone you want (akg or ety) plugged in Output A?')
display('Are you wearing an anti-static shock bracelet before you touch the preamp? Seriously.')

%%% Audio Settings

DEQ = 'BYPASS'; %DEQ set to BYPASS
systemfs = 96000;


                    
% subj = input('Please enter the the subject ID. : ','s');
% 
 same_cal = input('Use existing cal_rms value? y or n. :','s');

switch same_cal
    case 'n'
input('Place microphone in 250 Hz calibrator(set to 114db) and press button on the side of the calibrator. Press ENTER when ready.')
cal = rec_time(.5,systemfs,ff_input_dev);
cal_f = highpass(cal,20,systemfs,1);
cal_rms = rms(cal_f(:,1))
end
input('Switch microphone to Etymotic earphone output. Press ENTER when ready.')
[stim stimfs nbits] = wavread([wavfolder wavfilename]);
if size(stim,2) ==1
    stim = [stim stim];
end
if stimfs ~= systemfs
    if rem(systemfs,stimfs) == 0 
        clear resamp
        resampval = systemfs/stimfs;
        resamp(:,1) = resample(stim(:,1),systemfs,stimfs);
         resamp(:,2) = resample(stim(:,2),systemfs,stimfs);
    else
    error('Convert stimulus sample rate to a compatible sampling rate')
    end
end
stimrec =  rec_vec(resamp,systemfs,ff_input_dev,0,0.0031,1);
stimrec_f = highpass(stimrec,20,systemfs,1);
[z_rms] = rms(stimrec_f(:,1));
[a_rms a_stim] = aw_rms(stimrec(:,1),systemfs);
[c_rms c_stim] = cw_rms(stimrec(:,1),systemfs);

dBZ = amp2db(z_rms/cal_rms)+ 114;
dBA = amp2db(a_rms/cal_rms)+ 114;
dBC = amp2db(c_rms/cal_rms)+ 114;

dBZpeak = amp2db(max(abs(stimrec_f))/cal_rms)+ 114;
dBApeak = amp2db(max(abs(a_stim))/cal_rms)+ 114;
dBCpeak = amp2db(max(abs(c_stim))/cal_rms)+ 114;

%input('Switch the Fireface Mixer to Free Field. ')

save([wavfolder wavfilename 'dB'])
