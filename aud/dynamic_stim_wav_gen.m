function dynamic_stim_wav_gen(time)
%
%
%
%

load('Final Working Stims 500.mat')
stim_storage_to_wav(Final_Stim_Matrix_500, Parent_Stims_500, 1000, 500, time);
clear
load('Final Working Stims 1000.mat')
stim_storage_to_wav(Final_Stim_Matrix_1000, Parent_Stims_1000, 2000, 1000, time);
clear
load('Final Working Stims 2000.mat')
stim_storage_to_wav(Final_Stim_Matrix_2000, Parent_Stims_2000, 4000, 2000, time);
clear
load('Final Working Stims 4000.mat')
stim_storage_to_wav(Final_Stim_Matrix_4000, Parent_Stims_4000, 8000, 4000, time);
clear
