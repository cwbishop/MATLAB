function [mod_code, d]=HINT_modcheck_GUI(varargin)
%% DESCRIPTION:
%
%   Function to handle HINT scoring via the HINT GUI. When paired with
%   portaudio_adaptiveplay and a suitable modifier, this can be used to
%   administer the HINT. 
%
% INPUT:
%
%
%   'file_list':    cell array, sentences being presented. Note that
%                       the order should match the order of presentation as
%                       well. This machination is a little clunky and error
%                       prone - CWB needs to rethink things.
%
% OUTPUT:
%
%   'mod_code':     modification code.
%                       0:  no modification necessary.
%                       -1: make target quieter
%                       1:  make target louder
%
% Development:
%   XXX
%
% Christopher W. Bishop
%   University of Washington
%   5/14

%% INPUT CHECK AND DEFAULTS

% Grab trial count from portaudio_adaptiveplay.m.
%   Global variables are not CWB's favorite, but it's the least troublesome
%   way of ensuring that we are on the correct trial. 
global trial; 

% initialize mod_code to zero (do nothing) 
mod_code=0;

%% MASSAGE INPUT ARGS
% Convert inputs to structure
%   Users may also pass a parameter structure directly, which makes CWB's
%   life a lot easier. 
if length(varargin)>1
    p=struct(varargin{:}); 
elseif length(varargin)==1
    p=varargin{1};
elseif isempty(varargin)
    p=struct();     
end %

%% INPUT CHECK AND DEFAULTS
defs=SIN_defaults;
d=defs.hint; 

% OVERWRITE DEFAULTS
%   Overwrite defaults if user specifies something different.
flds=fieldnames(p);
for i=1:length(flds)
    d.(flds{i})=p.(flds{i}); 
end % i=1:length(flds)

%% IMPORT SENTENCES FROM FILE
%   This should only be run during initialization. 
%       - Read in sentence information from xlsx file. 
%       - Very slow step, so keep calls to a minimum. 
if ~isfield(p, 'sentence') || isempty(p.sentence)
    
    % Grab sentence information
    o=importHINT; 
    
    % Get fieldnames
    flds=fieldnames(o);
    
    % Copy this information over into the larger data structure. 
    for i=1:length(flds)
        d.(flds{i})=o.(flds{i}); 
    end % i=1:length(flds)
    clear o;
    
    %% Initialize other fields
    
    % Plotting information for HINT_GUI
    d.xdata=[];
    d.ydata=[];
    d.xlabel='Trial #';
    d.ylabel='SNR (dB)'; 
    d.ntrials=length(d.file_list); % number of trials (sets axes later)
    d.score_labels={'Correct', 'Incorrect'}; 

    % After we initialize, return control to invoking function
    %   This way we don't bring up the scoring GUI until after the first
    %   sentence is complete. 
    return; 
    
end % if ~isfield p ...

% FIND SENTENCE FOR SCORING
%   finds information for the sentence to be sored.
fname=d.file_list{trial}; 

% Stupid way to handle this, but a decent place to start.
fname=fname(end-12:end); 

% Find sentence information by matching the filepath between. 
o=importHINT('filepath', fname); 

%% CALL SCORING GUI
%   Pulls up a scoring GUI designed by CWB in GUIDE + lots of other manual
%   customizations. 
[fhand, score]=HINT_GUI(...
    'title', ['HINT: ' o.id{1} ' (' num2str(o.scoringunits) ' possible)'], ...
    'string', o.sentence{1}, ...
    'xdata', d.xdata, ...
    'ydata', d.ydata, ...
    'xlabel', d.xlabel, ...
    'ylabel', d.ylabel, ...
    'ntrials', d.ntrials, ...
    'score_labels', {d.score_labels}); 

% Copy figure handle over to d structure.
d.fhand=fhand; 

%% COPY SCORE INFORMATION OVER TO d STRUCTURE

%% DETERMINE IF A MODIFICATION IS NECESSARY
%   
% mod_mode=0; % hard coded for now for debugging. 
