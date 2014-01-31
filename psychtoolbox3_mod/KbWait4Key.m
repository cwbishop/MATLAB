function [RTIME, KEY_NUM]=KbWait4Key(TARGET_KEYS, SHOWKEYS)
%% DESCRIPTION:
%
%   Function to wait for user to press a specific key or one of several
%   target keys. Function uses KbCheck and returns control only after one
%   of the TARGET_KEYS is pressed.
%
% INPUT:
%
%   TARGET_KEYS:    integer array, key numbers (e.g., KbName('b'))
%   SHOWKEYS:       bool, flag to show key presses in MATLAB command
%                   window. (default=false)
% OUTPUT:
%
%   RTIME:      Time of button press as measured by KbCheck.
%   KEY_NUM:    integer, integer number for pressed target keys. 
%
% Christopher W. Bishop
%   University of Washington
%   1/14

%% INPUT AND DEFAULTS
if ~exist('SHOWKEYS', 'var') || isempty(SHOWKEYS), SHOWKEYS=false; end 

%% TURN OFF KEYBOARD DISPLAY
if ~SHOWKEYS
    ListenChar(2);
end % ~SHOWKEYS

% Quick keyboard check to populate variables
[~,RTIME,key_num] = KbCheck; 

% Check keyboard until a target key is pressed.
while ~any(key_num(TARGET_KEYS))
    [~,RTIME,key_num] = KbCheck;         
end % while any(key_num

%% DETERMINE WHICH KEYS WERE PRESSED
KEY_NUM=find(key_num==1);

%% ERROR CHECK FOR MULTIPLE, SIMULTANEOUS BUTTON PRESSES
%   If a user presses buttons simultaneously (or nearly so), then restart
%   response gathering.
%
%   14/01/31 CWB: Tested with two buttons held down prior to call to
%   KbWait4Key and this check detected the multiple button presses. Also,
%   it correctly called itself again.
%
%   Set SHOWKEYS to true so we don't needlessly call ListenChar. If set to
%   true, nothing is done.
if length(KEY_NUM)>1
    [RTIME, KEY_NUM]=KbWait4Key(TARGET_KEYS, true); 
end % if length(KEY_NUM)>1

%% RESET DISPLAY
%   Reset char settings so characters stream to matlab command line.
if ~SHOWKEYS
    ListenChar(0);
end % ~SHOWKEYS