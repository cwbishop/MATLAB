function results=gab_task_eeglab_runica(args)
%% DESCRIPTION
%
%   Wrapper for pop_runica. See pop_runica for details.
%
% INPUT:
%
%   args.icatype
%   args.dataset
%   args.chanind
%   args.concatenate
%
% OUTPUT:
%
%   results:    'done'
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

global EEG;

%% DEFAULTS
if ~isfield(args, 'dataset'), args.dataset=1; end
if ~isfield(args, 'chanind'), args.chanind=1:EEG.nbchan; end
if ~isfield(args, 'concatenate'), args.concatenate='on'; end
if ~isfield(args, 'icatype'), args.icatype='runica'; end

EEG=pop_runica(EEG, 'icatype', args.icatype, 'dataset', args.dataset, 'chanind', args.chanind, 'concatenate', args.concatenate);

results='done';