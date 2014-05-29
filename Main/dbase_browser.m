function varargout = dbase_browser(varargin)
% DBASE_BROWSER M-file for dbase_browser.fig
%      DBASE_BROWSER, by itself, creates a new DBASE_BROWSER or raises the existing
%      singleton*.
%
%      H = DBASE_BROWSER returns the handle to a new DBASE_BROWSER or the handle to
%      the existing singleton*.
%
%      DBASE_BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DBASE_BROWSER.M with the given input arguments.
%
%      DBASE_BROWSER('Property','Value',...) creates a new DBASE_BROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dbase_browser_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dbase_browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dbase_browser

% Last Modified by GUIDE v2.5 28-Jul-2010 11:07:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dbase_browser_OpeningFcn, ...
                   'gui_OutputFcn',  @dbase_browser_OutputFcn, ...
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


% --- Executes just before dbase_browser is made visible.
function dbase_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dbase_browser (see VARARGIN)

    % Choose default command line output for dbase_browser
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes dbase_browser wait for user response (see UIRESUME)
    % uiwait(handles.dbase_browser);
    
    global app
   
    % set up database connection
    sql_getResults = ['select DISTINCT tasks.TaskID, experiments.Notes, ' ...
                      'experiments.Date, experiments.Directory, experiments.Time ' ...
                      'from experiments inner join data ' ...
                      'on experiments.ExptID = data.ExptID ' ...
                      'inner join tasks on ' ...
                      'tasks.TaskID = data.TaskID ' ...
                      'where tasks.IsLSFinished = 1 order by ' ...
                      'experiments.Date, experiments.Time ASC'];               

    rsGetResults = mksqlite(sql_getResults);
    
    for i = 1 : length(rsGetResults)
        TaskID   = rsGetResults(i).TaskID;
        strNotes = rsGetResults(i).Notes;        
        strDate  = rsGetResults(i).Date;
        strTime  = rsGetResults(i).Time;
        string_list{i} = ['[' num2str(TaskID) '] - ' strDate ' ' strTime ' - ' strNotes];
    end
    
    app.viewCompleted = 1;
    app.showNucleus   = 0;
    
    set(handles.experiments,'String',string_list);    
    clear rsGetResults
    
    
% --- Outputs from this function are returned to the command line.
function varargout = dbase_browser_OutputFcn(hObject, eventdata, handles) 

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on selection change in experiments.
function experiments_Callback(hObject, eventdata, handles)

    global app

    str = get(hObject,'String');
    val = get(hObject,'Value');
    
    tag = str{val};
    idx = regexp(tag,'\[[0-9]{1,}\]');
    
    TaskID = [];
    stop = 0;
    i = idx(1)+1;
    
	while stop == 0
        if tag(i) ~= ']'
            TaskID = [TaskID tag(i)];
            i = i + 1;
        else
            stop = 1;
        end
    end
    
    app.TaskID = str2num(TaskID);
    
    % get directory for current Task
    sql_getDataID = ['select DataID from data where TaskID = ' num2str(TaskID) ' and IsI = 1'];
    rsGetDataID   = mksqlite(sql_getDataID);
    DataID        = rsGetDataID(1).DataID;
    pathname      = get_full_path(DataID,1);        
    

% --- Executes during object creation, after setting all properties.
function experiments_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
  
    
% --- Executes on button press in selectLE.
function selectLE_Callback(hObject, eventdata, handles)
% hObject    handle to selectLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('LE',0);

% --- Executes on button press in selectLO.
function selectLO_Callback(hObject, eventdata, handles)
% hObject    handle to selectLO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('LO',0);
    
% --- Executes on button press in selectLP.
function selectLP_Callback(hObject, eventdata, handles)
% hObject    handle to selectLP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('LP',0);

% --- Executes on button press in selectInit.
function selectInit_Callback(hObject, eventdata, handles)
% hObject    handle to selectInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('Init',0);

% --- Executes on button press in selectFlSeg.
function selectFlSeg_Callback(hObject, eventdata, handles)
% hObject    handle to selectFlSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('Fl',1);

% --- Executes on button press in selectISeg.
function selectISeg_Callback(hObject, eventdata, handles)
% hObject    handle to selectISeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('I',1);

% --- Executes on button press in selectImSeg.
function selectImSeg_Callback(hObject, eventdata, handles)
% hObject    handle to selectImSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('Im',1);
    
% --- Executes on button press in selectIpSeg.
function selectIpSeg_Callback(hObject, eventdata, handles)
% hObject    handle to selectIpSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('Ip',1);
    
% --- Executes on button press in selectIp.
function selectIp_Callback(hObject, eventdata, handles)
% hObject    handle to selectIp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('Ip',0);
    

% --- Executes on button press in selectIm.
function selectIm_Callback(hObject, eventdata, handles)
% hObject    handle to selectIm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('Im',0);
    
% --- Executes on button press in selectI.
function selectI_Callback(hObject, eventdata, handles)
% hObject    handle to selectI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('I',0);
    
% --- Executes on button press in selectFl.
function selectFl_Callback(hObject, eventdata, handles)
% hObject    handle to selectFl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    show_result('Fl',0);

    
% --- Tells main app which image to show    
function show_result(strImgType,blnSeg)

    global app
    
    hMainGui = getappdata(0, 'hMainGui'); 
    handles = guidata(hMainGui); 

    if blnSeg == 0
        set(handles.status,'String',['Displaying ' strImgType]);
    else
        set(handles.status,'String',['Displaying ' strImgType ' with Segmented Boundaries']);
    end
    
        
    fhShowResults = getappdata(hMainGui, 'fhShowResults');
    setappdata(hMainGui, 'TaskID', app.TaskID);
    setappdata(hMainGui, 'strImgType', strImgType);
    setappdata(hMainGui, 'blnSeg', blnSeg);
    setappdata(hMainGui, 'showNucl', app.showNucleus);
    feval(fhShowResults);
        
    

% --- Executes on button press in toggleInitFull.
function toggleInitFull_Callback(hObject, eventdata, handles)
% hObject    handle to toggleInitFull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global app
        
    % toggle the viewer between initialised and completed datasets
    if app.viewCompleted == 1
        
        % get initialised results
        sql_getResults = ['select DISTINCT tasks.TaskID, experiments.Notes, experiments.Date, ' ...
                          'experiments.Directory, experiments.Time ' ...
                          'from experiments inner join data ' ...
                          'on experiments.ExptID = data.ExptID ' ...
                          'inner join tasks on ' ...
                          'tasks.TaskID = data.TaskID ' ...
                          'where tasks.IsInit = 1 and tasks.IsLSFinished = 0 order by ' ...
                          'experiments.ExptID ASC'];   
                      
        app.viewCompleted = 0;
        set(handles.toggleInitFull,'String','Show Full Datasets');
        set(handles.selectIpSeg,'Enable','Off');
        set(handles.selectImSeg,'Enable','Off');
        set(handles.selectISeg,'Enable','Off');
        set(handles.selectFlSeg,'Enable','Off');
        
    else
        
        sql_getResults = ['select DISTINCT tasks.TaskID, experiments.Notes, experiments.Date, ' ...
                      'experiments.Directory, experiments.Time ' ...
                      'from experiments inner join data ' ...
                      'on experiments.ExptID = data.ExptID ' ...
                      'inner join tasks on ' ...
                      'tasks.TaskID = data.TaskID ' ...
                      'where tasks.IsLSFinished = 1 order by ' ...
                      'experiments.ExptID ASC'];   

        app.viewCompleted = 1;
        set(handles.toggleInitFull,'String','Show Init Datasets');
        set(handles.toggleInitFull,'String','Show Full Datasets');
        set(handles.selectIpSeg,'Enable','On');
        set(handles.selectImSeg,'Enable','On');
        set(handles.selectISeg,'Enable','On');
        set(handles.selectFlSeg,'Enable','On');
        
                  
    end
        
    rsGetResults = mksqlite(sql_getResults);
    
    for i = 1 : length(rsGetResults)
        TaskID   = rsGetResults(i).TaskID;
        strNotes = rsGetResults(i).Notes;
        strDate  = rsGetResults(i).Date;
        strTime  = rsGetResults(i).Time;
        string_list{i} = ['[' num2str(TaskID) '] - ' strDate ' ' strTime ' - ' strNotes];
    end
        
    set(handles.experiments,'String',string_list);    
    clear rsGetResults
    


% --- Executes on button press in segment_nuclei.
function segment_nuclei_Callback(hObject, eventdata, handles)
% hObject    handle to segment_nuclei (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global app
    
    TaskID = app.TaskID;
    sql_checkLSDone = ['select IsLSFinished from tasks where TaskID = ' num2str(TaskID)];    
    rsCheckLSDone = mksqlite(sql_checkLSDone);
    
    % check if level set segmentation is complete for this task - if
    % not, don't do anything
    if rsCheckLSDone(1).IsLSFinished == 1
        set(handles.status,'String','Performing nucleus segmentation');
        pause(0.01);
        
        % get directory for current Task
        sql_getDataID = ['select DataID from data where TaskID = ' num2str(TaskID) ' and IsI = 1'];
        rsGetDataID   = mksqlite(sql_getDataID);
        DataID        = rsGetDataID(1).DataID;
        pathname      = get_full_path(DataID,1);
        
        % get in-focus image for current Task
        sql_getImage = ['select Name from data where TaskID = ' num2str(TaskID) ...
                            ' and IsI = 1'];
        rsGetImage   = mksqlite(sql_getImage);
        filename     = rsGetImage(1).Name;
        
        clear rsGetDataID rsGetImage
        
        % load in-focus image
        if ~(isempty(findstr(filename,'ics')))
            I = double(icsread([pathname filename]));
        else
            I = double(imread([pathname filename]));
        end
        I = I / 255;
        
        % load seg result
        classes = double(imread([pathname 'out_classes.png']));
        
        % segment nuclei on image
        tic
        N = segment_nuclei(I,classes);
        % N = segment_nuclei_fine(I,classes);
        toc
        
        % save the nuclei segmentation result
        imwrite(N,[pathname 'out_nuclei.png'],'PNG');
        
        sql_doneNuclSeg = ['update tasks set IsNuclSeg = 1 where TaskID = ' num2str(TaskID)];
        mksqlite(sql_doneNuclSeg);
        
        % show segmentation result
        showNucleus = app.showNucleus;
        app.showNucleus = 1;
        show_result('Fl',1);
        
        % reset Show Nucleus status if necessary
        if showNucleus == 0
            app.showNucleus = 0;
        end
        
        set(handles.status,'String','');
        
    else
        set(handles.status,'String','Cannot do nucleus seg until LS seg is complete');
    end
    

% --- Executes on button press in show_seg_nuclei.
function show_seg_nuclei_Callback(hObject, eventdata, handles)
% hObject    handle to show_seg_nuclei (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_seg_nuclei

    global app
    
    blnShowSeg = get(hObject,'Value');
    if blnShowSeg == 0
        app.showNucleus = 0;
    else 
        app.showNucleus = 1;
    end
    
