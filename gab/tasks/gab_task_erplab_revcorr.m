function results = gab_task_erplab_revcorr(args)
%% DESCRIPTION:
%
%   This is a wrapper function for performing reverse correlation on ERP
%   data and audio files using erp_revcorr.m. 
%
% INPUTS:
%
% Params:
%
%   'erp_file': full path to file containing ERP structure.
%
%   'audio_track':    full path to file containing stimuli.
%
%   'erp_channels': 
%
%   'erp_bins':
%
%   'time_window':
%
%   'n_frequency_bands':
%
%   'seed_boosting':
%
%   'audio_channels':
%
%   'receptive_field_duration':
%
%   'save_to_file': full path to mat file with saved variables
%
% OUTPUT:
%
%   results:    hold over from GAB
%
% Christopher W Bishop
%   University of Washington 
%   12/14


erp_revcorr(args.params{:}); 

% 'erp_channels', 6, 'erp_bins', 1:2, 'time_window', [-inf inf], 'n_frequency_bands', 1, 'seed_boosting', false, 'audio_channels', 2, 'receptive_field_duration', 1);

results = 'done';