function results=gab_task_envvars(args)
%% DESCRIPTION
%
%   Extremely simple function to establish environmental variables
%   necessary to easily work with data in EEGLAB.  This is done by simply
%   starting EEGLAB and then ensuring that the user's special pathfiles are
%   checked before EEGLAB folders. User specific path directories must be
%   defined in startup.m
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2010

global EEG ALLEEG;
eeglab;
startup;

results='done';