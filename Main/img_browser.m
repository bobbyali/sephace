function varargout = img_browser(varargin)
% IMG_BROWSER Application M-file for img_browser.fig
%   IMG_BROWSER, by itself, creates a new IMG_BROWSER or raises the existing
%   singleton*.
%
%   H = IMG_BROWSER returns the handle to a new IMG_BROWSER or the handle to
%   the existing singleton*.
%
%   IMG_BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in IMG_BROWSER.M with the given input arguments.
%
%   IMG_BROWSER('Property','Value',...) creates a new IMG_BROWSER or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before img_browser_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to img_browser_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2000-2006 The MathWorks, Inc.

% Edit the above text to modify the response to help img_browser

% Last Modified by GUIDE v2.5 14-Oct-2009 16:28:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @img_browser_OpeningFcn, ...
                   'gui_OutputFcn',     @img_browser_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before img_browser is made visible.
function img_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to img_browser (see VARARGIN)

% Choose default command line output for img_browser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% set initial path
global startpath f2
startpath = pwd;
f2 = gcf;

% load a blank default image
blank = imread('sephace_seg.jpg');
axes(handles.axes1);
imagesc(blank);axis equal, axis off; axis tight;

if nargin == 3,
    initial_dir = pwd;
%     initial_dir = 'R:\Bobby';
elseif nargin > 4
    if strcmpi(varargin{1},'dir')
        if exist(varargin{2},'dir')
            initial_dir = varargin{2};
        else
            errordlg('Input argument must be a valid directory','Input Argument Error!')
            return
        end
    else
        errordlg('Unrecognized input argument','Input Argument Error!');
        return;
    end
end
% Populate the listbox
load_listbox(initial_dir,handles)
% Return figure handle as first output argument
    
% UIWAIT makes img_browser wait for user response (see UIRESUME)
% uiwait(handles.img_browser);




% --- Outputs from this function are returned to the command line.
function varargout = img_browser_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------------------------------------------------------------
% Callback for list box - open .fig with guide, otherwise use open
% ------------------------------------------------------------
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

global app

index_selected = get(handles.listbox1,'Value');
file_list = get(handles.listbox1,'String');
filename = file_list{index_selected};
if  handles.is_dir(handles.sorted_index(index_selected))
    cd (filename)
    load_listbox(pwd,handles)
    save = 0;
else
    [path,name,ext,ver] = fileparts(filename);
    switch ext
%         case '.fig'
%             guide (filename)
        case '.ics'
            I = icsread(filename);
            axes(handles.axes1);
            imagesc(I);colormap('gray'); 
            axis equal, axis off; axis tight;
            save = 1;
        case {'.bmp', '.tif', '.png'}
            I = imread(filename);
            axes(handles.axes1);
            imagesc(I);colormap('gray'); 
            axis equal, axis off; axis tight;                
            save = 1;
        otherwise
%             try
%                 open(filename)
%             catch
%                 errordlg(lasterr,'File Type Error','modal')
%             end
            set(handles.status,'String','Filetype not supported');
            save = 0;
    end
end

% app.img_browser.pathname = [pwd '/'];

if save == 1
    set(handles.set_Ip,'Enable','ON');
    set(handles.set_Im,'Enable','ON');
    set(handles.set_Fl,'Enable','ON');  
    set(handles.set_I,'Enable','ON'); 
    set(handles.set_Ipp,'Enable','ON'); 
    set(handles.set_Imm,'Enable','ON'); 
    app.browser.filename = filename;
else
    set(handles.set_Ip,'Enable','OFF');
    set(handles.set_Im,'Enable','OFF');
    set(handles.set_Fl,'Enable','OFF');
    set(handles.set_I,'Enable','OFF'); 
    set(handles.set_Ipp,'Enable','OFF'); 
    set(handles.set_Imm,'Enable','OFF');     
end



% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)

    global app
    
    cd (dir_path)
    dir_struct = dir(dir_path);
    [sorted_names,sorted_index] = sortrows({dir_struct.name}');
    handles.file_names = sorted_names;
    handles.is_dir = [dir_struct.isdir];
    handles.sorted_index = sorted_index;
    guidata(handles.img_browser,handles)
    set(handles.listbox1,'String',handles.file_names,...
        'Value',1)
    set(handles.text1,'String',pwd)
    
    % set up the load saved data button if current directory contains a
    % stored dataset
    savedata = 0;
    for i = 1 : length({dir_struct.name})
        if strcmp(dir_struct(i).name,'fileinfo.txt')
            savedata = 1;
        end
    end
    
    % save current path into global app variable
    app.browser.pathname = [pwd '/'];
   

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function img_browser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to img_browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Add the current directory to the path, as the pwd might change thru' the
% gui. Remove the directory from the path when gui is closed 
% (See browser_DeleteFcn)
setappdata(hObject, 'StartPath', pwd);
addpath(pwd);


% --- Executes during object deletion, before destroying properties.
function img_browser_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to img_browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove the directory added to the path in the browser_CreateFcn.
if isappdata(hObject, 'StartPath')
    rmpath(getappdata(hObject, 'StartPath'));
end

% return to original path
global startpath
cd(startpath);

% --- Executes on button press in set_Ip.
function set_Ip_Callback(hObject, eventdata, handles)
% hObject    handle to set_Ip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global app

hMainGui = getappdata(0, 'hMainGui');
fhUpdateIp = getappdata(hMainGui, 'fhUpdateIp');
setappdata(hMainGui, 'pathname', app.browser.pathname);
setappdata(hMainGui, 'filename', app.browser.filename);
feval(fhUpdateIp);


% --- Executes on button press in set_Im.
function set_Im_Callback(hObject, eventdata, handles)
% hObject    handle to set_Im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global app

hMainGui = getappdata(0, 'hMainGui');
fhUpdateIm = getappdata(hMainGui, 'fhUpdateIm');
setappdata(hMainGui, 'pathname', app.browser.pathname);
setappdata(hMainGui, 'filename', app.browser.filename);
feval(fhUpdateIm);

% --- Executes on button press in set_Fl.
function set_Fl_Callback(hObject, eventdata, handles)
% hObject    handle to set_Fl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global app

hMainGui = getappdata(0, 'hMainGui');
fhUpdateFl = getappdata(hMainGui, 'fhUpdateFl');
setappdata(hMainGui, 'pathname', app.browser.pathname);
setappdata(hMainGui, 'filename', app.browser.filename);
feval(fhUpdateFl);




% --- Executes on button press in set_I.
function set_I_Callback(hObject, eventdata, handles)
% hObject    handle to set_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global app

hMainGui = getappdata(0, 'hMainGui');
fhUpdateI = getappdata(hMainGui, 'fhUpdateI');
setappdata(hMainGui, 'pathname', app.browser.pathname);
setappdata(hMainGui, 'filename', app.browser.filename);
feval(fhUpdateI);

function drive_Callback(hObject, eventdata, handles)
% hObject    handle to drive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drive as text
%        str2double(get(hObject,'String')) returns contents of drive as a double

drive = get(handles.drive,'String');
drive = [drive ':\'];
load_listbox(drive,handles);


% --- Executes during object creation, after setting all properties.
function drive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in set_Ipp.
function set_Ipp_Callback(hObject, eventdata, handles)
% hObject    handle to set_Ipp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global app

hMainGui = getappdata(0, 'hMainGui');
fhUpdateIpp = getappdata(hMainGui, 'fhUpdateIpp');
setappdata(hMainGui, 'pathname', app.browser.pathname);
setappdata(hMainGui, 'filename', app.browser.filename);
feval(fhUpdateIpp);


% --- Executes on button press in set_Imm.
function set_Imm_Callback(hObject, eventdata, handles)
% hObject    handle to set_Imm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global app

hMainGui = getappdata(0, 'hMainGui');
fhUpdateImm = getappdata(hMainGui, 'fhUpdateImm');
setappdata(hMainGui, 'pathname', app.browser.pathname);
setappdata(hMainGui, 'filename', app.browser.filename);
feval(fhUpdateImm);


% --- Executes on button press in start_seg.
function start_seg_Callback(hObject, eventdata, handles)
% hObject    handle to start_seg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global app

global startpath
cd(startpath);

hMainGui = getappdata(0, 'hMainGui');
fhInitiateSingleSeg = getappdata(hMainGui, 'fhInitiateSingleSeg');
feval(fhInitiateSingleSeg);
