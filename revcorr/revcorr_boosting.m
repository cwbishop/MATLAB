function [h, pcc] = revcorr_boosting(X, Y, varargin)
%% DESCRIPTION:
%
%   This function serves as the primary function for performing reverse
%   correlation between two time series.
%
%   Function requires two time series X and Y. A predictive set of
%   coefficients are used to predict the best mapping of X to Y. That is,
%   the coefficients are effectively a FIR filter that can be used to
%   predict Y. 
%
%   As an illustrative example, consider a case in which a sound is played
%   to a listener while the brain response is simultaneously recorded using
%   EEG/MEG. X is the input signal (acoustic waveform) and Y is the output
%   signal (brain response)
%
% INPUT:
%
%   X:  input signal. This can be a time series or a file name to a file
%       containing a time series, provided loading is supported by
%       SIN_loaddata.
%
%   Y:  output signal. This can take the same formats as X.
%
% Parameters:
%
%   'fsx':  sampling rate of x in Hz. This parameter is only required is X
%           is a time series and ignored if X is loaded from file.
%
%   'fsy':  sampling rate of y in Hz. Same characteristics as fsx
%
% OUTPUT:
%
%   