function varargout = HINT_GUI(varargin)
% HINT_GUI MATLAB code for HINT_GUI.fig
%      HINT_GUI, by itself, creates a new HINT_GUI or raises the existing
%      singleton*.
%
%      H = HINT_GUI returns the handle to a new HINT_GUI or the handle to
%      the existing singleton*.
%
%      HINT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HINT_GUI.M with the given input arguments.
%
%      HINT_GUI('Property','Value',...) creates a new HINT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HINT_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HINT_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HINT_GUI

% Last Modified by GUIDE v2.5 06-May-2014 16:09:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HINT_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @HINT_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before HINT_GUI is made visible.
function HINT_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HINT_GUI (see VARARGIN)

% Choose default command line output for HINT_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Convert parameters to structure (easier to work with)
if length(varargin)>1
    p=struct(varargin{:}); 
elseif length(varargin)==1
    p=varargin{1};
elseif isempty(varargin)
    p=struct();     
end % if length ...

% Set defaults
%   'xlabel':
%   'ylabel':
%   'ntrials': number of trials to play (sets axis information)
%   'score_labels': cell array, scoring labels used in scoring boxes. These
%                   default to 'correct' and 'incorrect' 
%   'string':   string, the text (usually a sentence) to be sored. 
if ~isfield(p, 'xlabel'), p.xlabel='Trial #'; end 
if ~isfield(p, 'ylabel'), p.ylabel='SNR (dB)'; end 
if ~isfield(p, 'ntrials'), p.ntrials=20; end % set to 20 by default since we'll never have more than 20
if ~isfield(p, 'score_labels'), p.score_labels={'Correct', 'Incorrect'}; end 
    
% Create axis labels
%   Set XLabel, YLabel
set(get(findobj('Tag', 'panel_plot'), 'YLabel'), 'String', p.ylabel);
set(get(findobj('Tag', 'panel_plot'), 'XLabel'), 'String', p.xlabel);

% Label radio buttons 
%   Attach labels to radio buttons. Makes the GUI more flexible and useful
%   for reviewing other types of information related to HINT. 

% Set first option label
h=findobj(hObject, '-regexp', 'Tag', '^word[123456]_opt1');
for i=1:length(h)
    set(h(i), 'String', p.score_labels{1});
end % for i=1:length(h)

% Set section option label
h=findobj(hObject, '-regexp', 'Tag', '^word[123456]_opt2');
for i=1:length(h)
    set(h(i), 'String', p.score_labels{2});
end % for i=1:length(h)

% Set domain
xlim([0 p.ntrials]); 

% Set range

%% GENERATE SCORABLE WORD LIST

% First, parse sentence string into words. Create scoring flags
w=strsplit(p.string); 
isscored=zeros(length(w),1); % assume nothing is scored by default

%  Second, determine which words will be scored, assign word to text box,
%  then set visibility of scoring panel.
for i=1:length(w)
    
    % First, remove potential markups, like brackets ([]) and '/'
    tw=strrep(w{i}, '[', '');
    tw=strrep(tw, ']', '');
    tw=strrep(tw, '/', '');    
    
    % Second, assign word to word textbox
    h=findobj(hObject, 'Tag', ['word' num2str(i) '_text']);
    set(h, 'String', w{i});
    
    % Now, grab the scoring panel handle
    h=findobj(hObject, 'Tag', ['word' num2str(i) '_scoring']);
    
    % If all the letters are uppercase, then assume we'll score this word
    if isstrprop(w{i}, 'upper')
        isscored(i)=true; 
        set(h, 'Visible', 'on');        
    else
        isscored(i)=false; 
        set(h, 'Visible', 'off');        
    end % if isstrprop ...        
    
end % for i=1:length(w)

% Convert isscored to logical
%   Could be useful later to quickly determine if values for all scored
%   items are gathered when next button is clicked
isscored=logical(isscored); 



% UIWAIT makes HINT_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HINT_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in button_next.
function button_next_Callback(hObject, eventdata, handles)
% hObject    handle to button_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in record_checkbox.
function record_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to record_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of record_checkbox
