function varargout = img_loader(varargin)
% IMG_LOADER M-file for img_loader.fig
%      IMG_LOADER, by itself, creates a new IMG_LOADER or raises the existing
%      singleton*.
%
%      H = IMG_LOADER returns the handle to a new IMG_LOADER or the handle to
%      the existing singleton*.
%
%      IMG_LOADER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMG_LOADER.M with the given input arguments.
%
%      IMG_LOADER('Property','Value',...) creates a new IMG_LOADER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before img_loader_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to img_loader_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help img_loader

% Last Modified by GUIDE v2.5 27-Oct-2009 12:40:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @img_loader_OpeningFcn, ...
                   'gui_OutputFcn',  @img_loader_OutputFcn, ...
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


% --- Executes just before img_loader is made visible.
function img_loader_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to img_loader (see VARARGIN)

    % Choose default command line output for img_loader
    handles.output = hObject;

    % Enable sephaCe to return to original directory on closing
    set(handles.listener,'CloseRequestFcn',@closeGUI);
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes img_loader wait for user response (see UIRESUME)
    % uiwait(handles.listener);

    % set initial path
    global f2
    f2 = gcf;
           
    
% --- Outputs from this function are returned to the command line.
function varargout = img_loader_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function closeGUI(src,evnt)
%src is the handle of the object generating the callback (the source of the event)
%evnt is the The event data structure (can be empty for some callbacks)
    
    delete(gcbf);
    disp('Closing listener GUI');
    
    
% =========================================================================
%   Callbacks for input form fields
% =========================================================================

function strInputPath_Callback(hObject, eventdata, handles)
% hObject    handle to strInputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strInputPath as text
%        str2double(get(hObject,'String')) returns contents of strInputPath as a double

    sql_checkExptExists = ['select ExptID, Notes from experiments where Directory = "' lower(findreplace(get(hObject,'String'), '\', '\\')) '"'];
    rsCheckExptExists = mksqlite(sql_checkExptExists);
    if ~isempty(rsCheckExptExists)
        set(handles.strNotes,'String',rsCheckExptExists(1).Notes);        
    end
    clear rsCheckExptExists

    
% --- Executes during object creation, after setting all properties.
function strInputPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strInputPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strNotes_Callback(hObject, eventdata, handles)
% hObject    handle to strNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strNotes as text
%        str2double(get(hObject,'String')) returns contents of strNotes as a double


% --- Executes during object creation, after setting all properties.
function strNotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strPrefixImm_Callback(hObject, eventdata, handles)
% hObject    handle to strPrefixImm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strPrefixImm as text
%        str2double(get(hObject,'String')) returns contents of strPrefixImm as a double


% --- Executes during object creation, after setting all properties.
function strPrefixImm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strPrefixImm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strPrefixIm_Callback(hObject, eventdata, handles)
% hObject    handle to strPrefixIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strPrefixIm as text
%        str2double(get(hObject,'String')) returns contents of strPrefixIm as a double


% --- Executes during object creation, after setting all properties.
function strPrefixIm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strPrefixIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strPrefixFl_Callback(hObject, eventdata, handles)
% hObject    handle to strPrefixFl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strPrefixFl as text
%        str2double(get(hObject,'String')) returns contents of strPrefixFl as a double


% --- Executes during object creation, after setting all properties.
function strPrefixFl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strPrefixFl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strPrefixIpp_Callback(hObject, eventdata, handles)
% hObject    handle to strPrefixIpp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strPrefixIpp as text
%        str2double(get(hObject,'String')) returns contents of strPrefixIpp as a double


% --- Executes during object creation, after setting all properties.
function strPrefixIpp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strPrefixIpp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strPrefixIp_Callback(hObject, eventdata, handles)
% hObject    handle to strPrefixIp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strPrefixIp as text
%        str2double(get(hObject,'String')) returns contents of strPrefixIp as a double


% --- Executes during object creation, after setting all properties.
function strPrefixIp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strPrefixIp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strPrefixI_Callback(hObject, eventdata, handles)
% hObject    handle to strPrefixI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strPrefixI as text
%        str2double(get(hObject,'String')) returns contents of strPrefixI as a double


% --- Executes during object creation, after setting all properties.
function strPrefixI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strPrefixI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strSeparatorInit_Callback(hObject, eventdata, handles)
% hObject    handle to strSeparatorInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strSeparatorInit as text
%        str2double(get(hObject,'String')) returns contents of strSeparatorInit as a double


% --- Executes during object creation, after setting all properties.
function strSeparatorInit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strSeparatorInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strSeparatorFine_Callback(hObject, eventdata, handles)
% hObject    handle to strSeparatorFine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strSeparatorFine as text
%        str2double(get(hObject,'String')) returns contents of strSeparatorFine as a double


% --- Executes during object creation, after setting all properties.
function strSeparatorFine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strSeparatorFine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% =========================================================================


% --- Executes on button press in buttonStartListening.
function buttonStartListening_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStartListening (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global t listener
    
    strInputPath    = get(handles.strInputPath,'String');
    strNotes        = get(handles.strNotes,'String');
    
    % check if current 'experiment' (input directory) is in the database
    sql_checkExptExists = ['select ExptID from experiments where Directory = "' findreplace(lower(strInputPath), '\', '\\') '"'];
    rsCheckExptExists = mksqlite(sql_checkExptExists);
    if ~isempty(rsCheckExptExists)
        listener.newExptID = rsCheckExptExists(1).ExptID;
    else
    
        % new directory, so start new 'experiment' in database     
        sql_newExpt = ['insert into experiments (Directory, Notes) values (' ...                     
                         '"' findreplace(lower(strInputPath), '\', '\\') '",' ...
                         '"' strNotes '")'];
        mksqlite(sql_newExpt);

        % retrieve new experiment ID
        sql_getNewExptID = ['select ExptID from experiments order by ExptID DESC'];
        rsExptID = mksqlite(sql_getNewExptID);
        listener.newExptID = rsExptID(1).ExptID;
        clear rsExptID
    end
    clear rsCheckExptExists
    
    disp(['Starting listening on directory ' get(handles.strInputPath,'String')]);
    
    t = timer('StartDelay', 0,'Period', 10,'TasksToExecute', Inf,'ExecutionMode','fixedRate');
    t.TimerFcn = {@listener_callback,handles};
    start(t);
    set(handles.buttonStartListening,'Enable','Off');
    set(handles.buttonStopListening,'Enable','On');
    set(handles.strInputPath,'Enable','Off');    
    set(handles.strPrefixIpp,'Enable','Off');
    set(handles.strPrefixIp,'Enable','Off');
    set(handles.strPrefixImm,'Enable','Off');
    set(handles.strPrefixIm,'Enable','Off');
    set(handles.strPrefixI,'Enable','Off');
    set(handles.strPrefixFl,'Enable','Off');  
    set(handles.strSeparatorInit,'Enable','Off');
    set(handles.strSeparatorFine,'Enable','Off');
    set(handles.strNotes,'Enable','Off');
    set(handles.enableLS,'Enable','Off');
    
    

% --- Executes on button press in buttonStopListening.
function buttonStopListening_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStopListening (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global t
    
    stop(t);
    disp('Stopped listener.');
    set(handles.buttonStartListening,'Enable','On');
    set(handles.buttonStopListening,'Enable','Off');
    set(handles.strInputPath,'Enable','On');
    set(handles.strPrefixIpp,'Enable','On');
    set(handles.strPrefixIp,'Enable','On');
    set(handles.strPrefixImm,'Enable','On');
    set(handles.strPrefixIm,'Enable','On');
    set(handles.strPrefixI,'Enable','On');
    set(handles.strPrefixFl,'Enable','On');  
    set(handles.strSeparatorInit,'Enable','On');
    set(handles.strSeparatorFine,'Enable','On'); 
    set(handles.strNotes,'Enable','On');
    set(handles.enableLS,'Enable','On');
    
    % if LS is running when timer is stopped, then reset the database 
    % setting for that task back to being initialised only
    sql_resetRunningTasks = ['update tasks set IsLSRunning = 1 where ' ...
                             'IsLSRunning = 1 and IsLSFinished = 0'];
    mksqlite(sql_resetRunningTasks);
            
    
% --- Starts up listener.
function listener_callback(obj,event,handles)

    global listener
    
    hMainGui = getappdata(0, 'hMainGui');        
    ExptID   = listener.newExptID;
    
    % get string prefixes from form, add into global struct
    listener.strInputPath    = get(handles.strInputPath,'String');
    listener.strPrefixIpp    = get(handles.strPrefixIpp,'String');
    listener.strPrefixIp     = get(handles.strPrefixIp,'String');
    listener.strPrefixImm    = get(handles.strPrefixImm,'String');
    listener.strPrefixIm     = get(handles.strPrefixIm,'String');
    listener.strPrefixI      = get(handles.strPrefixI,'String');
    listener.strPrefixFl     = get(handles.strPrefixFl,'String');  
    listener.strSeparatorInit = get(handles.strSeparatorInit,'String');
    listener.strSeparatorFine = get(handles.strSeparatorFine,'String'); 
    listener.strIterations    = get(handles.strIterations,'String');
    
    % check whether LS has been enabled
    enableLS = get(handles.enableLS,'Value');
    
    % recursively go through directories and check all files in the 
    % directory tree are in database
    checkFilesAgainstDatabase(listener.strInputPath,0);
    
    % start processing tasks. first check for all new tasks in this 
    % experiment (where ExptID matches and IsFullSet = 0) 
    % to determine whether they have all the images required
    sql_getNewTasks = ['select distinct tasks.TaskID ' ...                    
                      'from tasks inner join data on tasks.TaskID = data.TaskID ' ...
                      'where tasks.IsFullSet = 0 and data.ExptID = ' num2str(ExptID)];
    rsTaskList = mksqlite(sql_getNewTasks);
    
    for i = 1 : length(rsTaskList)
        checkFullImageSetForTask(rsTaskList(i).TaskID);
    end
    
    % check for tasks where IsFullSet = 1 but IsInit = 0; do
    % initialisation; may want to do this last...
    sql_getNewTasks = ['select distinct tasks.TaskID ' ...                    
                      'from tasks inner join data on tasks.TaskID = data.TaskID ' ...
                      'where tasks.IsFullSet = 1 and tasks.IsInit = 0 ' ...
                      'and data.ExptID = ' num2str(ExptID)];
    rsTaskList = mksqlite(sql_getNewTasks);
    
    for i = 1 : length(rsTaskList)                
        % set up images in main app
        fhUpdateAll = getappdata(hMainGui, 'fhUpdateAll');
        setappdata(hMainGui, 'TaskID', rsTaskList(i).TaskID);
        feval(fhUpdateAll);
        
        % initiate initialisation
        fhInitiateFromListener = getappdata(hMainGui, 'fhInitiateFromListener');
        feval(fhInitiateFromListener);
        
        sql_isInit = ['update tasks set IsInit = 1 where TaskID = ' num2str(rsTaskList(i).TaskID)];
        mksqlite(sql_isInit);
    end

    % check for tasks where IsLSRunning = 1 and IsLSFinished = 0; check
    % whether they've finished, and the results can be saved
    sql_getNewTasks = ['select distinct tasks.TaskID ' ...                    
                      'from tasks inner join data on tasks.TaskID = data.TaskID ' ...
                      'where tasks.IsLSRunning = 1 and tasks.IsLSFinished = 0 ' ...
                      'and data.ExptID = ' num2str(ExptID)];
    rsTaskList = mksqlite(sql_getNewTasks);
    
    if ~isempty(rsTaskList)
        % set up images in main app
        fhUpdateAll = getappdata(hMainGui, 'fhUpdateAll');
        setappdata(hMainGui, 'TaskID', rsTaskList(1).TaskID);
        feval(fhUpdateAll);

        % show latest image from LS in app
        fhShowLSInProgress = getappdata(hMainGui, 'fhShowLSInProgress');
        feval(fhShowLSInProgress);

        % if max num of iterations is reached, then flag as
        % completed
        try
            iterations    = load('_out_iterations.txt');
            if iterations == (str2num(listener.strIterations) - 1)
                sql_isDone = ['update tasks set IsLSFinished = 1 where TaskID = ' num2str(rsTaskList(1).TaskID)];
                mksqlite(sql_isDone);
                disp('Completed Level Set job');
            end
        end
        
    else           
        
        % check for tasks where IsInit = 1 but IsLSRunning = 0; if there is no
        % task where IsLsRunning = 1 and IsLSFinished = 0, then start it up in
        % the background
        sql_getInitTasks = ['select distinct tasks.TaskID ' ...                    
                          'from tasks inner join data on tasks.TaskID = data.TaskID ' ...
                          'where tasks.IsInit = 1 and tasks.IsLSRunning = 0 ' ...
                          'and data.ExptID = ' num2str(ExptID)];
        rsInitTaskList = mksqlite(sql_getInitTasks);

        % only process the first one if more than one, and if user has
        % enabled LS processing
        if ~isempty(rsInitTaskList) && enableLS == 1
               
            % set up images in main app
            fhUpdateAll = getappdata(hMainGui, 'fhUpdateAll');
            setappdata(hMainGui, 'TaskID', rsInitTaskList(1).TaskID);
            feval(fhUpdateAll);
    
            % initiate initialisation
            fhStartLSFromListener = getappdata(hMainGui, 'fhStartLSFromListener');
            setappdata(hMainGui, 'Iterations', listener.strIterations);
            feval(fhStartLSFromListener);

            % update database
            sql_startedLS = ['update tasks set IsLSRunning = 1 where TaskID = ' num2str(rsInitTaskList(1).TaskID)];
            mksqlite(sql_startedLS);
            
        end
    end
    
    clear rsTaskList rsInitTaskList
    disp('Completed a listen cycle');
    
    
% recursive function, goes through all directories in a given directory 
% tree and checks whether contents are images/directories, and whether
% they're in the database ('data' table). if not, it puts them in
function checkFilesAgainstDatabase(strInputPath,ParentDirID)

    global listener
    
    ExptID = listener.newExptID;
    
    filelist = dir(strInputPath);
    
    % check if there are any task numbers assigned to the files in the
    % current directory
    TaskID = 0;
    sql_checkTaskNumber = ['select DISTINCT TaskID from data where ' ...
                            'ExptID = ' num2str(ExptID) ' and ' ...
                            'ParentDirID = ' num2str(ParentDirID)];
    rsCheckTaskNumber = mksqlite(sql_checkTaskNumber);
    if ~isempty(rsCheckTaskNumber)
        % there is an existing TaskID
        TaskID = rsCheckTaskNumber(1).TaskID;
        
    else
        % no TaskID for files in folder, so check if there are any images
        blnImagesInDir = 0;
        for i = 1 : length(filelist)
            if  (~isempty(regexpi(filelist(i).name, 'ics', 'once')) || ...
                 ~isempty(regexpi(filelist(i).name, 'bmp', 'once')) || ...
                 ~isempty(regexpi(filelist(i).name, 'tif', 'once')))
             
                blnImagesInDir = 1;
                break
            end            
        end
        
        % if an image was found in the directory, then create a new TaskID
        if blnImagesInDir == 1
            sql_newTask = ['insert into tasks (IsFullSet) values (0)'];
            mksqlite(sql_newTask);
            sql_getNewTaskID = ['select TaskID from tasks order by TaskID DESC'];
            rsTaskID = mksqlite(sql_getNewTaskID);
            TaskID = rsTaskID(1).TaskID;
            clear rsTaskID   
        end
        
    end    
    
    % loop through files in current directory, check for
    % images/subdirectories, and check whether they're already in dbase
    for i = 1 : length(filelist)        
        
        % check that item is either an image file (ics,bmp,tif) or a
        % directory, or doesn't end in 'tmp' (sometimes ICS files get saved
        % as .ics.tmp before being finally saved as .ics)
        if  (~isempty(regexpi(filelist(i).name, 'ics', 'once')) || ...
             ~isempty(regexpi(filelist(i).name, 'bmp', 'once')) || ...
             ~isempty(regexpi(filelist(i).name, 'tif', 'once')) || ...             
             filelist(i).isdir == 1) && ...
            (strcmp(filelist(i).name,'.') == 0 && ...
             strcmp(filelist(i).name,'..') == 0) && ...
             isempty(regexpi(filelist(i).name,'tmp$'))
             
             % item is valid, check it exists in database
             sql_checkFileExists = ['select Name from data Where Name = "' filelist(i).name '" ' ...
                                    'and TaskID = ' num2str(TaskID)];
             rsFileExists = mksqlite(sql_checkFileExists);
             
             % if file doesn't exist, add to database
             if isempty(rsFileExists)                            
                sql_addNewItem = ['insert into data (Name,IsDir,TaskID,ParentDirID,ExptID) values (' ...
                                    '"' filelist(i).name '",' ...
                                     num2str(filelist(i).isdir) ',' ...
                                     num2str(TaskID) ',' ...
                                     num2str(ParentDirID) ',' ...
                                     num2str(ExptID) ')'];
                mksqlite(sql_addNewItem);            
             end
             
             % if item is a directory then check inside it
             if filelist(i).isdir == 1
                 childDirectoryFullPath = [strInputPath '\' filelist(i).name];
                 sql_getParentDirID = ['select DataID from data where Name = "' filelist(i).name '"'];
                 rsParentDirID = mksqlite(sql_getParentDirID);
                 newParentDirID = rsParentDirID(1).DataID;
                 checkFilesAgainstDatabase(childDirectoryFullPath,newParentDirID);                 
             end
             
             clear tmpParentDirID newParentDirID rsFileExists
        end
                
    end
    
% look for the files for a task, and make sure they're all present. if they
% are, the database gets updated with annotations defining each image as
% Ipp/Imm/Ip/Im/I/Fl
function checkFullImageSetForTask(TaskID)

    global listener
    
    ExptID = listener.newExptID;
        
    strPrefixIpp = listener.strPrefixIpp;
    strPrefixIp  = listener.strPrefixIp;
    strPrefixImm = listener.strPrefixImm;
    strPrefixIm  = listener.strPrefixIm;
    strPrefixI   = listener.strPrefixI;
    strPrefixFl  = listener.strPrefixFl;
    strSeparatorInit = listener.strSeparatorInit ;
    strSeparatorFine = listener.strSeparatorFine;
    
    images.Ipp = [];
    images.Imm = [];
    images.I   = [];
    images.Ip  = [];
    images.Im  = [];
    images.Fl  = [];
    
    sql_checkFilesForTask = ['select DataID, Name from data where IsDir = 0 and TaskID = ' num2str(TaskID)];
    rsCheckFilesForTask   = mksqlite(sql_checkFilesForTask);
    
    % set this flag to 1 when we have all the images
    blnFullSet = 0;
    
    % check that there are enough files in the Task set (Imm,Ipp,Ip,Im,I)
    if length(rsCheckFilesForTask) > 4
        
        % check what kinds of files we're expecting - either each image has
        % a unique prefix, or Ipp/Imm and Ip/Im/I share prefixes.
        if strcmp(strPrefixImm,strPrefixIpp) == 1
            blnInitSamePrefix = 1;
            intInitImageCount = 0;
        else
            blnInitSamePrefix = 0;
        end
        
        if strcmp(strPrefixIm,strPrefixIp) == 1
            blnFineSamePrefix = 1;
            intFineImageCount = 0;
        else
            blnFineSamePrefix = 0;
        end
        
        % tick off each required file
        for i = 1 : length(rsCheckFilesForTask)
            
            file = rsCheckFilesForTask(i).Name;
            fileID = rsCheckFilesForTask(i).DataID;
            
            if blnInitSamePrefix == 1
                if ~isempty(regexpi(file,strPrefixIpp))
                    initImages{intInitImageCount+1} = file;
                    initImageIDs(intInitImageCount+1) = fileID;
                    intInitImageCount = intInitImageCount + 1;
                end
            else
                if ~isempty(regexpi(file,strPrefixIpp))
                   images.Ipp = fileID;
                end
                if ~isempty(regexpi(file,strPrefixImm))
                   images.Imm = fileID;
                end
            end
            
            if blnFineSamePrefix == 1
                if ~isempty(regexpi(file,strPrefixIp))
                    fineImages{intFineImageCount+1} = file;
                    fineImageIDs(intFineImageCount+1) = fileID;
                    intFineImageCount = intFineImageCount + 1;
                end
            else
                if ~isempty(regexpi(file,strPrefixIp))
                   images.Ip = fileID;
                end
                if ~isempty(regexpi(file,strPrefixIm))
                   images.Im = fileID;
                end
                if ~isempty(regexpi(file,strPrefixI))
                   images.I = fileID;
                end
            end
            
            if ~isempty(regexpi(file,strPrefixFl))
                   images.Fl = fileID;
            end
                            
        end
        
        % if prefixes are shared, go through files and pick out required
        % images. assume we're sorting on basis of Z values, although time
        % values should also work (as microscope z-drive goes from -ve to
        % +ve); make sure that cell array of image filenames exists first
        if blnInitSamePrefix == 1 && exist('initImages')
            for i = 1 : length(initImages)
               initSortValues(i) = analyseFileName(initImages{i}, strSeparatorInit);
            end
            
            % Ipp will be the image with the highest Z value
            images.Ipp = initImageIDs(find(initSortValues == max(initSortValues)));
            images.Imm = initImageIDs(find(initSortValues == min(initSortValues)));
            
        end
        
        if blnFineSamePrefix == 1 && exist('fineImages')
            for i = 1 : length(fineImages)
               fineSortValues(i) = analyseFileName(fineImages{i}, strSeparatorFine);
            end
                       
            % Ipp will be the image with the highest Z value; Imm will be
            % the image with the lowest Z value; I should be in the middle 
            images.Ip = fineImageIDs(find(fineSortValues == max(fineSortValues)));
            images.Im = fineImageIDs(find(fineSortValues == min(fineSortValues)));
            images.I  = fineImageIDs(find(fineSortValues == median(fineSortValues)));
            
        end
        
        % check that we have the images we need
        blnFullSet = 1;
        if isempty(images.Ip) || isempty(images.Im) || ...
                isempty(images.Ipp) || isempty(images.Imm) || ...
                isempty(images.I)
            blnFullSet = 0;
        end
                        
    end
    
    if blnFullSet == 1
        % set IsFullSet to 1 in tasks table - task now ready for initialisation
        disp('Loaded new directory of images into database');
        sql_hasFullSet = ['update tasks set IsFullSet = 1 where TaskID = ' num2str(TaskID)];
        mksqlite(sql_hasFullSet);
        
        % apply annotations to database. may not have Fl. only update when
        % the flags are set to zero
        sql_setIpp = ['update data set IsIpp = 1 where DataId = ' num2str(images.Ipp) ' and IsIpp = 0'];
        sql_setImm = ['update data set IsImm = 1 where DataId = ' num2str(images.Imm) ' and IsImm = 0'];
        sql_setIp  = ['update data set IsIp  = 1 where DataId = ' num2str(images.Ip) ' and IsIp = 0'];
        sql_setIm  = ['update data set IsIm  = 1 where DataId = ' num2str(images.Im) ' and IsIm = 0'];
        sql_setI   = ['update data set IsI   = 1 where DataId = ' num2str(images.I) ' and IsI = 0'];
                
        mksqlite(sql_setIpp);
        mksqlite(sql_setImm);
        mksqlite(sql_setIp);
        mksqlite(sql_setIm);
        mksqlite(sql_setI);
        
        if ~isempty(images.Fl)
            sql_setFl  = ['update data set IsFl  = 1 where DataId = ' num2str(images.Fl) ' and IsFl = 0'];
            mksqlite(sql_setFl);
        end
        
    end


% --- Executes on button press in enableLS.
function enableLS_Callback(hObject, eventdata, handles)
% hObject    handle to enableLS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enableLS



function strIterations_Callback(hObject, eventdata, handles)
% hObject    handle to strIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strIterations as text
%        str2double(get(hObject,'String')) returns contents of strIterations as a double


% --- Executes during object creation, after setting all properties.
function strIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
