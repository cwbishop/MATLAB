function [rf, pcc, audio_env, erp_data, FS] = erp_revcorr(varargin)
%% DESCRIPTION:
%
%   This function performs reverse correlation between an ERP data set and
%   an acoustic waveform. This is essentially a semi-convenient wrapper for
%   J. Simon and Nai Ding's reverse correlation code. Please contact these
%   authors directly for code (jzsimon@umd.edu). This also relies on the
%   NSL software suite (<http://www.isr.umd.edu/Labs/NSL/Software.htm>)
%   which must be downloaded and in your path. 
%
% INPUT:
%
% Parameters:
%
%   'erp':  ERPlab structure or the file path to a file containing the ERP
%           structure. See SIN_loaddata for more information
%
%   'audio_track':  path to file containing audio information. 
%
%   'erp_channels': double array, ERP channels to perform reverse
%                   correlation with. 
%
%   'erp_bins':     double array, bins to include in reverse correlation
%                   routine.
%
%   'time_window':  two-element array, specifies the time window for
%                   analysis (e.g., [5 inf] excludes the first 5 sec from
%                   the ERP and audio_track
%   
%   'n_frequency_bands':    number of frequency bands to use in audio track
%                           envelope estimation.
%
%   'seed_boosting':    bool, if set, RFgen_multichan will seed the boosting
%                       algorithm with its first pass estimate. Note: this
%                       will effectively be false if n_frequency_bands is
%                       set to 1. 
%
%   'audio_channels':   integer, which audio channel(s) to use in reverse
%                       correlation estimation. Note: CWB has only tried
%                       this with a single channel and cannot verify that
%                       it works with multiple channels (yet). 
%
%   'receptive_field_duration': receptive field duration in seconds.
%
%   'remove_mean':  bool, if set, the mean is removed from the selected
%                   time window of the ERP data. 
%
%   'save_to_file': path to mat file with saved variables. (default = '',
%                   variables are not saved) 
%
% Development:
%
%   1. Extend to work with multiple audio channels. 
%
% Christopher W. Bishop
%   University of Washington
%   12/14

%% LOAD PARAMETERS
opts = varargin2struct(varargin{:});

% Set defaults
if ~isfield(opts, 'save_to_file'), opts.save_to_file = ''; end

% Load the ERPLab structure
[erp_data, erp_fs] = SIN_loaddata(opts.erp, ...
    'chans', opts.erp_channels, ...
    'bins', opts.erp_bins, ...
    'time_window',  opts.time_window .* 1000);  % convert time stamp to millisecond

% Remove mean from ERP data
%   Remove the mean for each data channel/condition
if opts.remove_mean
   
    for c=1:size(erp_data,1)
        
        for b=1:size(erp_data,3)
            m = []; 
            % Find the mean
            m = mean(squeeze(erp_data(c,:,b)));
            
            % Subtract mean from these data
            erp_data(c,:,b) = erp_data(c,:,b) - m; 
            
        end % for b=1:
        
    end % for c=1:
end % opts.remove_mean

% Time-frequency decomposition and envelope estimation of audio_track
%   This also resamples the audio data to match the sampling rate of our
%   ERP data. 
[audio_env, CF] = audSpec_env(opts.audio_track, ...
    'output_fs',erp_fs, ...
    'n_frequency_bands', opts.n_frequency_bands);

% Only use first channel
audio_env = audio_env{opts.audio_channels}; 

% Truncate longer of two data sets to match the shorter of the two sets
max_length = min([size(audio_env,2) size(erp_data,2)]); 
erp_data = erp_data(:,1:max_length,:);
audio_env = audio_env(:,1:max_length); 
    
% Copy envelope for each condition
audio_env = repmat(audio_env, 1, 1, size(erp_data,3)); 

% Run reverse correlation
[rf, pcc] = RFgen_multichan(audio_env, erp_data, erp_fs, opts.receptive_field_duration, opts.seed_boosting); 

% Save the variables to a mat file?
if ~isempty(opts.save_to_file)
    
    % Save all variables to file 
    save(opts.save_to_file)
    
end % 

% Create some potentially useful plots
% if opts.pflag
    
    % STRF Plot
    
    % Predicted vs. Measured Time Course
    
    
    
% end % if opts.pflag

% Estimate neural "decoder"
%   This provides complementary information about how well the stimulus can
%   be predicted from the neural response. 
% [audio_env, audio_fs, CF] = audSpec_env(audio_track, erp_fs, 1);
% [rf, pcc] = RFgen_multichan(erp_data, audio_env{1}, erp_fs, 1, 0); 