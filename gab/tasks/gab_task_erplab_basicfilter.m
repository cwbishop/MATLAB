function [results]=gab_task_erplab_basicfilter(args)
%% DESCRIPTION:
%
% INPUT:
%
%   These inputs are taken directly from pop_basicfilter.m.  Please refer
%   to pop_basicfilter.m for a complete description of these variables.  A
%   brief description of each is provided here.
%
%   args.
%
%       chanArray   - channel(s) to filter
%       params:     parameters for pop_basicfilter as a string
%       %     'Filter'      - 'bandpass'- Band pass.
%                     'lowpass' - Low pass (attenuate high frequency).
%                     'highpass'- High pass (attenuate low frequency.
%                     'PMnotch' - stop-band Parks-McClellan Notch.
%     'Design'      - type of filter. 'butter' = IIR Butterworth,'fir'= windowed FIR
%     'Cutoff'      - lower cutoff (high-pass) pass and higher cuttof (low-pass) in the format [lower higher]
%     'Order'       - length of the filter in points {default 3*fix(srate/locutoff)}
%     'RemoveDC'    - remove mean value (DC offset) before filtering. 'on'/'off'
%     'Boundary'    - specify boundary event code. e.g 'boundary'
%           
% OUTPUT:
%
%   results:    'done'
%
% Bishop, Christopher W.
%   UC Davis
%   University of Washington 
%   11/2013

global EEG;

EEG = eval(['pop_basicfilter(EEG, args.chanArray,' args.params ');']);
% [EEG ferror] = basicfilter(EEG, chanArray, locutoff, hicutoff, filterorder, typef, remove_dc, boundary)
% EEG=pop_basicfilter( EEG, args.chanArray, args.locutoff, args.hicutoff, args.filterorder, args.typef, args.remove_dc, args.boundary

results='done';