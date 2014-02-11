function [results]=gab_task_eeglab_interp(args)
%% DESCRIPTION:
%
%   Simple wrapper for EEGLAB's eeg_interp function.
%
% INTPUT:
%
%   args.
%      badchans - [integer array] indices of channels to interpolate.
%                 For instance, these channels might be bad.
%                [chanlocs structure] channel location structure containing
%                either locations of channels to interpolate or a full
%                channel structure (missing channels in the current 
%                dataset are interpolated).badchannels: 
%     method   - [string] method used for interpolation (default is 'spherical').
%                'invdist' uses inverse distance on the scalp
%                'spherical' uses superfast spherical interpolation. 
%                'spacetime' uses griddata3 to interpolate both in space 
%                and time (very slow and cannot be interupted).
%
% OUTPUT:
%
%   results:
%
% Bishop CW

global EEG;

EEG=eeg_interp(EEG, args.badchans, args.method); 

results='done';