function varargout = Audiogram_GUI(varargin)


global study_dir
study_dir = 'C:\Miller11Backup196\Documents and Settings\jrkerlin\My Documents\code\utils\aud\trunk\Audiogram\';

% AUDIOGRAM_GUI M-file for Audiogram_GUI.fig
%      AUDIOGRAM_GUI, by itself, creates a new AUDIOGRAM_GUI or raises the existing
%      singleton*.
%
%      H = AUDIOGRAM_GUI returns the handle to a new AUDIOGRAM_GUI or the handle to
%      the existing singleton*.
%
%      AUDIOGRAM_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUDIOGRAM_GUI.M with the given input arguments.
%
%      AUDIOGRAM_GUI('Property','Value',...) creates a new AUDIOGRAM_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Audiogram_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Audiogram_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Audiogram_GUI

% Last Modified by GUIDE v2.5 10-Jul-2008 17:47:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Audiogram_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @Audiogram_GUI_OutputFcn, ...
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





% --- Executes just before Audiogram_GUI is made visible.
function Audiogram_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Audiogram_GUI (see VARARGIN)

% Choose default command line output for Audiogram_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using Audiogram_GUI.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes Audiogram_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = Audiogram_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in Rerun.
function Rerun_Callback(hObject, eventdata, handles)
% hObject    handle to Rerun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global type_string
[full_name, study_dir, Ind] = Upload(handles);
Ind;
audiogram_script(full_name,study_dir,Ind, type_string);
Upload(handles);



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in Freq_popup.
function Freq_popup_Callback(hObject, eventdata, handles)
% hObject    handle to Freq_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Freq_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Freq_popup


% --- Executes during object creation, after setting all properties.
function Freq_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Freq_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
global cond_names

cond_names = {
    'Left 125',
    'Left 250',
    'Left 500',
    'Left 750',
    'Left 1000',
    'Left 1500',
    'Left 2000',
    'Left 3000',
    'Left 4000',
    'Left 6000',
    'Left 8000',
    'Left 11200',
    'Left 16000',
    'Right 125',
    'Right 250',
    'Right 500',
    'Right 750',
    'Right 1000',
    'Right 1500',
    'Right 2000',
    'Right 3000',
    'Right 4000',
    'Right 6000',
    'Right 8000',
    'Right 11200',
    'Right 16000'};



set(hObject, 'String', cond_names);

%set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});



% --- Executes on button press in Runall.
function Runall_Callback(hObject, eventdata, handles)
% hObject    handle to Runall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[full_name, study_dir, Ind] = Upload(handles);
global FLev
global freq_str
global type_string
flag = 1;
file_path = [study_dir '\data\' full_name '.mat'];
if exist(file_path)
    response = questdlg(['A previous recording for ' full_name ' already exists. Warning!!! Previous data detected. Do you wish to overwrite previous data, continue incomplete trials, or cancel?'],'WARNING!!! Previous data detected','Overwrite','Continue','Cancel','Cancel');
    switch response
        case 'Overwrite'
            flag = 1;
            FLev = zeros(1,length(freq_str)*2);
        case 'Continue'
            flag = 1;
            load(file_path);
        case 'Cancel'
            flag = 0
    end
end
if flag == 1
    if any(FLev)
        inds = find(FLev == 0);
        scramble = randperm(length(inds));
        Ind = inds(scramble);
    else
        Ind = 0;
    end

    audiogram_script(full_name,study_dir,Ind, type_string);
    [full_name, study_dir, Ind] = Upload(handles);
end


function SubID_Callback(hObject, eventdata, handles)
% hObject    handle to SubID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SubID as text
%        str2double(get(hObject,'String')) returns contents of SubID as a double


% --- Executes during object creation, after setting all properties.
function SubID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadPrevData.
function LoadPrevData_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPrevData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function Type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function Type_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function Run_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes when selected object is changed in Run.
function Run_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Run
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in First.
function First_Callback(hObject, eventdata, handles)
% hObject    handle to First (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of First



% --- Executes on button press in update.
function update_Callback(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Upload(handles);




function [full_name, study_dir, Ind] = Upload(handles)
global study_dir
dBVals;
global freq_str
freq_str = {
    '125',
    '250',
    '500',
    '750',
    '1000',
    '1500',
    '2000',
    '3000',
    '4000',
    '6000',
    '8000',
    '11200',
    '16000'};
global FLev

Ind = get(handles.Freq_popup,'Value');
sub_string = get(handles.SubID, 'String');

if get(handles.First, 'Value');
    run_string = '1';
else
    run_string = '2';
end
global type_string
if get(handles.AKG, 'Value')
    type_string = 'akg';
    %%% From AKG grand average of the gold_standard participants
        grand_dbl = akg_thresh_attn(:);

elseif get(handles.ETY, 'Value')
    
    type_string = 'ety';
    %%% From ETY grand average of the gold_standard participants
    grand_dbl = ety_thresh_attn(:);  
elseif get(handles.IRC, 'Value')
    type_string = 'irc';
     %%% From ETY grand average of the gold_standard participants
        grand_dbl =  ety_thresh_attn(:); %%%default to same as ety
elseif get(handles.Custom, 'Value')
    type_string = 'custom'; 
     %%% From ETY grand average of the gold_standard participants
            grand_dbl =   ety_thresh_attn(:); %%%default to same as ety
end

full_name = [sub_string '_' type_string '_' run_string];
file_path = [study_dir '\data\' full_name '.mat'];

if exist(file_path)
    load(file_path);
else
    FLev = zeros(1,length(freq_str)*2);
end
axes(handles.axes1);
cla;

if exist(file_path)
plot(FLev(1:length(freq_str))-grand_dbl(1:length(freq_str))','b');
ylim([-120 30])
hold on
plot(FLev(length(freq_str)+1:2*length(freq_str))-grand_dbl(length(freq_str)+1:2*length(freq_str))','r');
else
 plot(FLev(1:length(freq_str)),'b');
ylim([-120 30]) 
hold on
plot(FLev(length(freq_str)+1:2*length(freq_str)),'r');   
end
legend('Left','Right');
set(gca, 'XTick', [1:length(freq_str)]);
set(gca, 'XTickLabel', freq_str);












% --- Executes on button press in Custom.
function Custom_Callback(hObject, eventdata, handles)
% hObject    handle to Custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Custom


