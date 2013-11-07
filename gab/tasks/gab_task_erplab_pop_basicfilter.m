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
%         'Filter'      
%                   'bandpass'- Band pass.
%                   'lowpass' - Low pass (attenuate high frequency).
%                   'highpass'- High pass (attenuate low frequency.
%                   'PMnotch' - stop-band Parks-McClellan Notch.
%       'Design'     - type of filter. 
%                   'butter' = IIR Butterworth,
%                   'fir'= windowed FIR
%       'Cutoff'     - lower cutoff (high-pass) pass and higher cuttof (low-pass) in the format [lower higher]
%       'Order'      - length of the filter in points {default 3*fix(srate/locutoff)}
%       'RemoveDC'   - remove mean value (DC offset) before filtering. 
%                    'on'/'off'
%       'Boundary'   - specify boundary event code. e.g 'boundary'
%           
% OUTPUT:
%
%   results:    'done'
%
% EXAMPLE:
%
%     ERP.task{end+1}=struct(...
%         'func', @gab_task_erplab_basicfilter, ...
%         'args', struct( ...
%             'chanArray', 1, ...
%             'params', ...
%                 {{'Filter', 'bandpass', ...
%                 'Design', 'butter', ...
%                 'Cutoff', [0.1 30], ...
%                 'Order', 4, ...
%                 'RemoveDC', 'on', ...
%                 'Boundary', 'boundary'}}));
%
% Bishop, Christopher W.
%   UC Davis
%   University of Washington 
%   11/2013

global EEG;

% pop_function is more human-readable, so we'll use this to parse our
% inputs into inputs that basicfilter actually understands.
EEG = pop_basicfilter(EEG, args.chanArray, args.params{:}); 

results='done';