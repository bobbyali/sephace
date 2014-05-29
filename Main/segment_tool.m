function varargout = segment_tool(varargin)
    % SEGMENT_TOOL M-file for segment_tool.fig
    %      Graphical interface for phase-based brightfield cell segmentation
    %      algorithm (Ali et al, ISBI 20087, submitted)
    %
    %      Requires two brightfield images (equal distance +/- in-focus image).
    %      A fluorescence image can also be provided to compare against the
    %      segmentation results.
    %
    % Last Modified by GUIDE v2.5 14-Oct-2009 16:29:03

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @segment_tool_OpeningFcn, ...
                       'gui_OutputFcn',  @segment_tool_OutputFcn, ...
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

% --- Executes just before segment_tool is made visible.
function segment_tool_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to segment_tool (see VARARGIN)

    % Choose default command line output for segment_tool
    handles.output = hObject;
    
    % Enable sephaCe to return to original directory on closing
    set(handles.sephaCe,'CloseRequestFcn',@closeGUI);

    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes segment_tool wait for user response (see UIRESUME)
    % uiwait(handles.sephaCe);

    % set up links to subwindow for image browser
    setappdata(0  , 'hMainGui'    , gcf);
    setappdata(gcf, 'fhUpdateIp', @updateIp);
    setappdata(gcf, 'fhUpdateIm', @updateIm);
    setappdata(gcf, 'fhUpdateIpp', @updateIpp);
    setappdata(gcf, 'fhUpdateImm', @updateImm);    
    setappdata(gcf, 'fhUpdateI',  @updateI);
    setappdata(gcf, 'fhInitiateSingleSeg', @initiateSingleSeg);
    
    % set up links to subwindow for image listener
    setappdata(gcf, 'fhUpdateAll',  @updateAll);
    setappdata(gcf, 'fhInitiateFromListener', @initiateFromListener);
    setappdata(gcf, 'fhStartLSFromListener', @startLSFromListener);
    setappdata(gcf, 'fhShowLSInProgress', @showLSInProgress);
    
    % set up links to subwindow for database (results) browser
    setappdata(gcf, 'fhShowResults', @showResults);
    
    % set up global struct to pass data around
    global app f1 f2
    f1 = gcf;
    clc

    app.initpath = [pwd '/'];

    % enforce use of native open dialog boxes (nicer than Matlab defaults)
    setappdata(0,'UseNativeSystemDialogs',0);  % http://www.mathworks.com/matlabcentral/newsreader/view_thread/73094

    % load a blank default image
    blank = imread('sephace_seg.jpg');
    axes(handles.axes1);
    imagesc(blank);axis off;axis equal;
    app.images.blank = blank;

    clearGlobal;
    
    mksqlite('open','sephaCe.db');


% --- Outputs from this function are returned to the command line.
function varargout = segment_tool_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;    
    
function clearGlobal

    global app;
    
    % set up common global variable 'app' fields
    app.images.Ip.filename = [];
    app.images.Ip.pathname = [];
    app.images.Ip.data = [];
    app.images.Im.filename = [];
    app.images.Im.pathname = [];
    app.images.Im.data = [];
    app.images.Fl.filename = [];
    app.images.Fl.pathname = [];
    app.images.Fl.data = [];
    app.images.I.filename = [];
    app.images.I.pathname = [];
    app.images.I.data = [];
    app.images.manual.filename = [];
    app.images.manual.pathname = [];
    app.images.manual.data = [];
    app.images.Ipp.filename = [];
    app.images.Ipp.pathname = [];
    app.images.Ipp.data = [];
    app.images.Imm.filename = [];
    app.images.Imm.pathname = [];
    app.images.Imm.data = [];
    app.local_orient = [];
    app.local_energy = [];
    app.local_phase = [];
    app.init_classes = [];
    
% =========================================================================
%    CALLBACKS FROM IMG_BROWSER (for manual selection of images)
% =========================================================================
function updateIp

    global app

    hMainGui = getappdata(0, 'hMainGui');
    pathname = getappdata(hMainGui, 'pathname');
    filename = getappdata(hMainGui, 'filename');  
    
    app.images.Ip.filename = filename;
    app.images.Ip.pathname = pathname;

    if ~(isempty(findstr(filename,'ics')))
        Ip = icsread([pathname filename]);
    else
        Ip = imread([pathname filename]);
    end
    Ip = double(Ip);

    handles = guidata(hMainGui);    
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(Ip);colormap('gray'); 
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');

    app.images.Ip.data = Ip;
    set(handles.status,'String','Loaded Positive Brightfield Image');


function updateIm

    global app

    hMainGui = getappdata(0, 'hMainGui');
    pathname = getappdata(hMainGui, 'pathname');
    filename = getappdata(hMainGui, 'filename');

    app.images.Im.filename = filename;
    app.images.Im.pathname = pathname;

    if ~(isempty(findstr(filename,'ics')))
        Im = icsread([pathname filename]);
    else
        Im = imread([pathname filename]);
    end
    Im = double(Im);

    handles = guidata(hMainGui);
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(Im);colormap('gray'); 
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');

    app.images.Im.data = Im;
    set(handles.status,'String','Loaded Negative Brightfield Image');

    
function updateIpp

    global app

    hMainGui = getappdata(0, 'hMainGui');
    pathname = getappdata(hMainGui, 'pathname');
    filename = getappdata(hMainGui, 'filename');

    app.images.Ipp.filename = filename;
    app.images.Ipp.pathname = pathname;

    if ~(isempty(findstr(filename,'ics')))
        Ipp = icsread([pathname filename]);
    else
        Ipp = imread([pathname filename]);
    end
    Ipp = double(Ipp);

    handles = guidata(hMainGui);
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(Ipp);colormap('gray'); 
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');

    app.images.Ipp.data = Ipp;
    set(handles.status,'String','Loaded Defocused Positive Brightfield Image');


function updateImm

    global app

    hMainGui = getappdata(0, 'hMainGui');
    pathname = getappdata(hMainGui, 'pathname');
    filename = getappdata(hMainGui, 'filename');

    app.images.Imm.filename = filename;
    app.images.Imm.pathname = pathname;

    if ~(isempty(findstr(filename,'ics')))
        Imm = icsread([pathname filename]);
    else
        Imm = imread([pathname filename]);
    end
    Imm = double(Imm);

    handles = guidata(hMainGui);
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(Imm);colormap('gray'); 
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');

    app.images.Imm.data = Imm;
    set(handles.status,'String','Loaded Defocused Negative Brightfield Image');    
    
function updateFl

    global app

    hMainGui = getappdata(0, 'hMainGui');
    pathname = getappdata(hMainGui, 'pathname');
    filename = getappdata(hMainGui, 'filename');

    app.images.Fl.filename = filename;
    app.images.Fl.pathname = pathname;

    if ~(isempty(findstr(filename,'ics')))
        Fl = icsread([pathname filename]);
    else
        Fl = imread([pathname filename]);
    end

    handles = guidata(hMainGui);
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(Fl);colormap('gray'); 
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');

    app.images.Fl.data = Fl;
    set(handles.status,'String','Loaded Fluorescence Image');

function updateI

    global app

    hMainGui = getappdata(0, 'hMainGui');
    pathname = getappdata(hMainGui, 'pathname');
    filename = getappdata(hMainGui, 'filename');

    app.images.I.filename = filename;
    app.images.I.pathname = pathname;

    if ~(isempty(findstr(filename,'ics')))
        I = icsread([pathname filename]);
    else
        I = imread([pathname filename]);
    end
    I = double(I);
    
    handles = guidata(hMainGui);
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(I);colormap('gray'); 
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');

    app.images.I.data = I;
    set(handles.status,'String','Loaded Brightfield In-Focus Image');  
    

function initiateSingleSeg

    global app
    
    hMainGui = getappdata(0, 'hMainGui');
    handles = guidata(hMainGui);
    
     initialise_segmentation;
%    initialise_segmentation_alt;
    
    iterations = '50';
    alpha   = '5';
    beta    = '0';
    gamma   = '5';
    delta   = '5';    
    
    c       = clock;
    year    = num2str(c(1));
    month   = num2str(c(2));
    day     = num2str(c(3));
    hour    = num2str(c(4));
    min     = num2str(c(5));
    newpath = ['data/' year '_' month '_' day '_' hour '_' min];
    mkdir(newpath);
    newpath = [newpath '/'];

    app.newpath = newpath;

    imwrite(app.init_classes/255, [newpath 'label_start.png'], 'PNG');
    imwrite(norm_image(app.local_phase), [newpath 'localphase.png'], 'PNG');
    imwrite(norm_image(app.local_orient), [newpath 'localorient.png'], 'PNG');
    imwrite(norm_image(app.local_energy), [newpath 'localenergy.png'], 'PNG');
    imwrite(norm_image(app.images.Ip.data), [newpath 'Ip.png'], 'PNG');
    imwrite(norm_image(app.images.Im.data), [newpath 'Im.png'], 'PNG');
    if ~isempty(app.images.Fl.data)
        imwrite(app.images.Fl.data, [newpath 'Fl.png'], 'PNG');
    end
    if ~isempty(app.images.I.data)
        imwrite(norm_image(app.images.I.data), [newpath 'I.png'], 'PNG');
    end   
    if ~isempty(app.images.Ipp.data)
        imwrite(norm_image(app.images.Ipp.data), [newpath 'Ipp.png'], 'PNG');
    end
    if ~isempty(app.images.Imm.data)
        imwrite(norm_image(app.images.Imm.data), [newpath 'Imm.png'], 'PNG');
    end
    
    delete _out_classes.png
    delete _out_phi.png
    delete _out_iterations.txt
    delete _out_volume.txt   
    
%     dos(['localphaseLS.exe ' newpath 'localphase.png ' newpath 'label_start.png ' newpath 'localorient.png ' newpath 'out_classes.png ' newpath 'out_phi.png ' iterations ' 1 ' ... 
%         alpha ' ' beta ' ' gamma ' ' delta ' &']);    

    set(handles.status,'String','Running Level Set in background...');  
    
    fid = fopen('runLS.bat','w+');
    modpath = findreplace(newpath,'\','\\');
    fprintf(fid,['localphaseLS.exe ' ...
                  modpath 'localphase.png ' ... 
                  modpath 'label_start.png ' ... 
                  modpath 'localorient.png ' ... 
                  modpath 'out_classes.png ' ... 
                  modpath 'out_phi.png ' ... 
                  iterations ' 1 ' ... 
                  alpha ' ' beta ' ' gamma ' ' delta ' \n']);
    fprintf(fid,'exit\n');
    fclose(fid);  
    dos(['runLS.bat &']);
    
    global t
        
    t = timer('StartDelay', 10,'Period', 20,'TasksToExecute', Inf,'ExecutionMode','fixedRate');
    t.TimerFcn = {@listener_callback};
    start(t);
    
    
% --- display binary/label map over grayscale image    
function R = display_RGB(L)

    global app
    
    I = app.images.I.data;
    R  = zeros(size(I,1),size(I,2),3);
    tmp = I;
    tmp(find(L ~= 1)) = 255;
    R(:,:,1) = tmp/255;
    R(:,:,2) = I/255;
    R(:,:,3) = I/255;

    
% --- Starts up listener for single segmentations.
function listener_callback(obj,event)

    global app t
    
    try
        phi           = double(imread('_out_phi.png'));
        final_classes = double(imread('_out_classes.png'));
        iterations    = load('_out_iterations.txt');

        hMainGui = getappdata(0, 'hMainGui');
        handles = guidata(hMainGui);

        set(handles.axes1,'HandleVisibility','ON');
        axes(handles.axes1);
        imagesc(app.images.I.data);colormap('gray');
        axis equal, axis off; axis tight; hold on;
        [ ct, h1] = contour( phi, [128 128] );
        set( h1, 'LineColor', [1 0 0] );
        set( h1, 'LineWidth', 1 );hold off; 
        set(handles.axes1,'HandleVisibility','OFF');

        set(handles.status,'String',['Iteration: ' num2str(iterations)]);

        if iterations == 49        
            stop(t);
        end
    end
    
% =========================================================================
%    CALLBACKS FROM IMG_LOADER (for automatic loading of images)
% =========================================================================

% --- receive images from the listener, put into global 'app' variable for 
%     use in other functions called by listener
function updateAll

    global app

    hMainGui = getappdata(0, 'hMainGui');
    
    TaskID = getappdata(hMainGui, 'TaskID');

    % get path containing image files    
    sql_getDataID = ['select DataID from data where TaskID = ' num2str(TaskID) ' and IsI = 1'];
    rsGetDataID   = mksqlite(sql_getDataID);
    DataID        = rsGetDataID(1).DataID;
    path = get_full_path(DataID,1);
    clear rsGetDataID
    
    % get images for current task
    sql_getIpp = ['select Name from data where TaskID = ' num2str(TaskID) ' and IsIpp = 1'];
    rsGetIpp   = mksqlite(sql_getIpp);
    strIpp     = rsGetIpp(1).Name;
    
    sql_getImm = ['select Name from data where TaskID = ' num2str(TaskID) ' and IsImm = 1'];
    rsGetImm   = mksqlite(sql_getImm);
    strImm     = rsGetImm(1).Name;    
    
    sql_getIp  = ['select Name from data where TaskID = ' num2str(TaskID) ' and IsIp  = 1'];
    rsGetIp    = mksqlite(sql_getIp );
    strIp      = rsGetIp(1).Name;
    
    sql_getIm  = ['select Name from data where TaskID = ' num2str(TaskID) ' and IsIm = 1'];
    rsGetIm    = mksqlite(sql_getIm);
    strIm      = rsGetIm(1).Name;
    
    sql_getI   = ['select Name from data where TaskID = ' num2str(TaskID) ' and IsI = 1'];
    rsGetI     = mksqlite(sql_getI);
    strI       = rsGetI(1).Name;
    
    clearGlobal;
    if ~(isempty(findstr(strImm,'ics')))
        app.images.Imm.data = double(icsread([path strImm]));
        app.images.Ipp.data = double(icsread([path strIpp]));
        app.images.Im.data  = double(icsread([path strIm]));
        app.images.Ip.data  = double(icsread([path strIp]));
        app.images.I.data   = double(icsread([path strI]));
    else
        app.images.Imm.data = double(imread([path strImm]));
        app.images.Ipp.data = double(imread([path strIpp]));
        app.images.Im.data  = double(imread([path strIm]));
        app.images.Ip.data  = double(imread([path strIp]));
        app.images.I.data   = double(imread([path strI]));
    end
       
    app.images.Imm.pathname = path; app.images.Imm.filename = strImm;
    app.images.Ipp.pathname = path; app.images.Ipp.filename = strIpp;
    app.images.Im.pathname  = path; app.images.Im.filename  = strIm;
    app.images.Ip.pathname  = path; app.images.Ip.filename  = strIp;
    app.images.I.pathname   = path; app.images.I.filename   = strI;
    

% call initialisation function from listener
function initiateFromListener    

    global app
    
    hMainGui = getappdata(0, 'hMainGui');
    handles = guidata(hMainGui);
    
    path = app.images.Ip.pathname;
    
    % initialise segmentation
    %initialise_segmentation;
    initialise_segmentation_alt;
         
    % save monogenic signal results to hard disk
    %    save [path 'results'] app.local_phase app.local_orient app.local_energy app.init_classes    
    imwrite(app.init_classes/255, [path 'label_start.png'], 'PNG');
    imwrite(norm_image(app.local_phase), [path 'localphase.png'], 'PNG');
    imwrite(norm_image(app.local_orient), [path 'localorient.png'], 'PNG');
    imwrite(norm_image(app.local_energy), [path 'localenergy.png'], 'PNG');
    
    set(handles.status,'String',['Image set in [' path '] now initialised']);
    disp('Completed initialiation for set of images');
    
    
% --- start Level Set from listener    
function startLSFromListener

    global app
   
    hMainGui = getappdata(0, 'hMainGui');
    handles = guidata(hMainGui);
    strIterations = getappdata(hMainGui, 'Iterations');
    
    path = app.images.Ip.pathname;
    
    iterations = strIterations;
    alpha   = '5';
    beta    = '2.5';
    gamma   = '2.5';
    delta   = '5';    
    
    % clear out files from last LS run
    delete _out_classes.png
    delete _out_phi.png
    delete _out_iterations.txt
    delete _out_volume.txt
    
%     dos(['localphaseLS.exe ' ... 
%           path 'localphase.png ' ... 
%           path 'label_start.png ' ... 
%           path 'localorient.png ' ... 
%           path 'out_classes.png ' ... 
%           path 'out_phi.png ' ... 
%           iterations ' 1 ' ... 
%           alpha ' ' beta ' ' gamma ' ' delta ' &']);
             
    fid = fopen('runLS.bat','w+');
    modpath = findreplace(path,'\','\\');
    fprintf(fid,['localphaseLS.exe ' ...
                  modpath 'localphase.png ' ... 
                  modpath 'label_start.png ' ... 
                  modpath 'localorient.png ' ... 
                  modpath 'out_classes.png ' ... 
                  modpath 'out_phi.png ' ... 
                  iterations ' 1 ' ... 
                  alpha ' ' beta ' ' gamma ' ' delta ' \n']);
    fprintf(fid,'exit\n');
    fclose(fid);  
    dos(['runLS.bat &']);
    
    set(handles.status,'String',['Running Level Set in background [' path ']']);    
    disp('Started new Level Set job');
    
    
% --- display latest update from Level Set   
function showLSInProgress
        
    global app
    
    hMainGui = getappdata(0, 'hMainGui');
    handles = guidata(hMainGui);
    
    try 
        phi           = double(imread('_out_phi.png'));
        final_classes = double(imread('_out_classes.png'));
        iterations    = load('_out_iterations.txt');

        set(handles.axes1,'HandleVisibility','ON');
        axes(handles.axes1);
        imagesc(app.images.I.data);colormap('gray');
        axis equal, axis off; axis tight; hold on;
        [ ct, h1] = contour( phi, [128 128] );
        set( h1, 'LineColor', [1 0 0] );
        set( h1, 'LineWidth', 1 );hold off; 
        set(handles.axes1,'HandleVisibility','OFF');

        set(handles.status,'String',['Iteration: ' num2str(iterations) ' [' app.images.Ip.pathname ']']);
    end
    
    

% =========================================================================
%    CALLBACKS FROM DBASE_BROWSER (for displaying results)
% =========================================================================

% --- shows the results selected by the database browser
function showResults

    global app

    hMainGui = getappdata(0, 'hMainGui');
    handles = guidata(hMainGui); 
    
    % get parameters from dbase_browser
    TaskID      = getappdata(hMainGui, 'TaskID');
    strImgType  = getappdata(hMainGui, 'strImgType');
    blnSeg      = getappdata(hMainGui, 'blnSeg');   
    showNucl    = getappdata(hMainGui, 'showNucl');
        
    % get path containing image files    
    sql_getDataID = ['select DataID from data where TaskID = ' num2str(TaskID) ' and IsI = 1'];
    rsGetDataID   = mksqlite(sql_getDataID);
    DataID        = rsGetDataID(1).DataID;
    pathname      = get_full_path(DataID,1);
    clear rsGetDataID

    % if there's no nucleus segmentation file, then set show nucleus to
    % OFF
    if ~exist([pathname 'out_nuclei.png'])
        showNucl = 0;
    end    
    
    blnColour = 0;
    
    % find and load image
    switch strImgType
        case 'LE'            
            filename = 'localenergy.png';
            caption  = ['Displaying Local Energy image [' pathname ']'];
            blnColour = 1;
        case 'LP'
            filename = 'localphase.png';
            caption  = ['Displaying Local Phase image [' pathname ']'];
            blnColour = 1;
        case 'LO'
            filename = 'localorient.png';
            caption  = ['Displaying Local Orientation image [' pathname ']'];
            blnColour = 1;
        case 'Init'
            filename = 'label_start.png';
            caption  = ['Displaying Initialisation image [' pathname ']'];
            blnColour = 1;
        case 'Im'
            sql_getImage = ['select Name from data where TaskID = ' num2str(TaskID) ...
                            ' and IsIm = 1'];
            rsGetImage   = mksqlite(sql_getImage);
            filename     = rsGetImage(1).Name;
            clear rsGetImage
            caption  = ['Displaying negative defocused Im image [' pathname ']'];
        case 'Ip'
            sql_getImage = ['select Name from data where TaskID = ' num2str(TaskID) ...
                            ' and IsIp = 1'];
            rsGetImage   = mksqlite(sql_getImage);
            filename     = rsGetImage(1).Name;
            clear rsGetImage
            caption  = ['Displaying positive defocused Ip image [' pathname ']'];
        case 'I'
            sql_getImage = ['select Name from data where TaskID = ' num2str(TaskID) ...
                            ' and IsI = 1'];
            rsGetImage   = mksqlite(sql_getImage);
            filename     = rsGetImage(1).Name;
            clear rsGetImage
            caption  = ['Displaying in-focus I image [' pathname ']'];
        case 'Fl'
            sql_getImage = ['select Name from data where TaskID = ' num2str(TaskID) ...
                            ' and IsFl = 1'];
            rsGetImage   = mksqlite(sql_getImage);
            filename     = rsGetImage(1).Name;
            clear rsGetImage
            caption  = ['Displaying Fluorescence image [' pathname ']'];
    end

    if ~(isempty(findstr(filename,'ics')))
        I = double(icsread([pathname filename]));
    else
        I = double(imread([pathname filename]));
    end
    
    if strcmpi(strImgType,'Init') > 0
        % for initialisation images, superimpose over in-focus image
        sql_getImage = ['select Name from data where TaskID = ' num2str(TaskID) ...
                        ' and IsI = 1'];
        rsGetImage   = mksqlite(sql_getImage);
        filename     = rsGetImage(1).Name;
        if ~(isempty(findstr(filename,'ics')))
            app.images.I.data = double(icsread([pathname filename]));
        else
            app.images.I.data = double(imread([pathname filename]));
        end
        clear rsGetImage
        I = display_RGB(I);
    end
    
    cmin = min(min(I));
    cmax = max(max(I));
    
    % display image with/without segmentation result overlaid
    if blnSeg == 0
        set(handles.axes1,'HandleVisibility','ON');
        axes(handles.axes1);
        imagesc(I);
        if blnColour == 0
            colormap('gray');
        else
            colormap('jet');
        end
        axis equal, axis off; axis tight;
        set(handles.axes1,'HandleVisibility','OFF');
    else

        % show boundary segmentation alone
        phi = double(imread([pathname 'out_phi.png']));
        set(handles.axes1,'HandleVisibility','ON');
        axes(handles.axes1);
        imagesc(I);colormap('gray');
        set(handles.axes1,'CLim',[cmin cmax]);
        axis equal, axis off; axis tight; hold on;

        % eradicate holes within seg results
        phi_bw = phi;
        phi_bw(phi < 128) = 1;
        phi_bw(phi >= 128) = 0;
        phi_bw = imfill(phi_bw,'holes');
        [ ct, h1] = contour( phi_bw, [0 0] );
        set( h1, 'LineColor', 'r' );
        set( h1, 'LineWidth', 1 );
        
        if showNucl == 1
            % show nucleus segmentations as well
            nuclSeg = double(imread([pathname 'out_nuclei.png']));
            nuclSeg = imfill(nuclSeg);
            [ ct, h1] = contour( nuclSeg, [0 0] );
            set( h1, 'LineColor', 'g' );
            set( h1, 'LineWidth', 1 );
        end
        
        hold off; 
        set(handles.axes1,'HandleVisibility','OFF');
        
    end
    
    set(handles.status,'String',caption);
    
    
% =========================================================================    

function closeGUI(src,evnt)
%src is the handle of the object generating the callback (the source of the event)
%evnt is the The event data structure (can be empty for some callbacks)

    global app

    selection = questdlg('Do you want to close sephaCe?',...
                         'Close Request Function',...
                         'Yes','No','Yes');
    switch selection,
       case 'Yes',
        delete(gcf)
        close all
       case 'No'
         return
    end

    cd(app.initpath)
    mksqlite('close');
    

    
% --- initialise the segmentation (find cells, compute local phase and 
%     local orientation
function initialise_segmentation    

    global app
    
    I = app.images.I.data;
    Ip = app.images.Ip.data;
    Im = app.images.Im.data;
    Ipp = app.images.Ipp.data;
    Imm = app.images.Imm.data;        
    path = app.images.Ip.pathname;
    
    hMainGui = getappdata(0, 'hMainGui');
    handles = guidata(hMainGui); 
    
    L = auto_detect_cells(Imm,Ipp);        
    L = L + 1;  % need bg = 1 for LS
    R = display_RGB(L);    
       
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(R);
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');    
    set(handles.status,'String',['Found ' num2str(max(max(L))-1) ' cells [' path ']']);  
        
    pause(0.1);
    
    diff = Im - Ip;
    [f, A, theta, psi] = fastMonogenic(diff);
    local_energy = norm_image(A);
    local_phase  = norm_image_zeromean(psi);
    local_orient = norm_image(theta)*2*pi;
    set(handles.status,'String',['Computed local phase... [' path ']']);
    
    app.init_classes = L;
    app.local_energy = local_energy;
    app.local_phase  = local_phase;
    app.local_orient = local_orient;
    
    
% --- initialise the segmentation (find cells, compute local phase and 
%     local orientation) - Alternative method
function initialise_segmentation_alt    

    global app
    
    I = app.images.I.data;
    Ip = app.images.Ip.data;
    Im = app.images.Im.data;
    Ipp = app.images.Ipp.data;
    Imm = app.images.Imm.data;        
    path = app.images.Ip.pathname;
                        
    hMainGui = getappdata(0, 'hMainGui');
    handles = guidata(hMainGui); 
    
    % compute local phase, orientation
    diff = Im - Ip;
    [f, A, theta, psi] = fastMonogenic(diff);
    local_energy = norm_image(A);
    local_phase  = norm_image_zeromean(psi);
    local_orient = norm_image(theta)*2*pi;
    set(handles.status,'String',['Computed local phase... [' path ']']);
    
    % detect cells
    L = auto_detect_cells(Imm,Ipp);        
    
    % ------------------------------------
%     % improve initialisation using local phase
%     n = 3;
%     [dimX,dimY] = size(I);
%     v = variance_map(I,n);
%     v1 = v(n:dimX-n,n:dimY-n);
%     mask = im2bw(v,graythresh(v1));
%     
%     mask = medfilt2(mask);
%     se   = strel('disk',5);
%     mask = imerode(mask,se);
%     mask = imdilate(mask,se);
%     mask = imfill(mask,'holes');
%     mask = double(mask);
%     
%     L    = multiregiongrow(mask,L);
%     numcells = max(max(L));
%     
% %     % smooth off edges on initialisation results
% %     mask = L;
% %     mask(L > 0) = 1;
% %     mask = imerode(mask,se);
% %     L(mask == 0) = 0;     
    % ------------------------------------
    % improve initialisation with selunummi method
    [dx dy] = size(diff);
    tmp = zeros(dx,dy,3);
    tmp(:,:,1) = Ip;
    tmp(:,:,2) = I;
    tmp(:,:,3) = Im;
    C = std(tmp,0,3)./mean(tmp,3);
    Is = C / max(max(C));
    h = fspecial('gaussian',5,5);
    Is = imfilter(Is,h);
    Is = norm_image(log(Is));
    It = im2bw(Is,graythresh(Is));
    P = IdentifySecPropagateSubfunction(L,Is,It,0.05);
    P = imfill(P,'holes');   
    L = P;
    
%     % smooth off edges on initialisation results
%     mask = L;
%     mask(L > 0) = 1;
%     se   = strel('disk',10);
%     mask = imerode(mask,se);
%     L(mask == 0) = 0;
%     
%     % remove small objects
%     mask = L;
%     mask = size_filter(mask);
%     L(mask == 0) = 0;
    % ------------------------------------
    L = L + 1;  % need bg = 1 for LS
    numcells = max(max(L)) - 1;
    R = display_RGB(L);    
       
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    imagesc(R);
    axis equal, axis off; axis tight;
    set(handles.axes1,'HandleVisibility','OFF');    
    set(handles.status,'String',['Found ' num2str(numcells) ' cells [' path ']']);  
        
    app.init_classes = L;
    app.local_energy = local_energy;
    app.local_phase  = local_phase;
    app.local_orient = local_orient;
    
    


% --- Get the complete path to the input item     
function strFullPath = get_full_path(DataID,blnReturnDir)
    
    sql_IsDir = ['select data.Name, data.IsDir, data.ParentDirID, ' ...
                 'experiments.Directory from experiments inner join ' ...
                 'data on experiments.ExptID = data.ExptID ' ...
                 'where DataID = ' num2str(DataID)];             
    rsIsDir   = mksqlite(sql_IsDir);
    blnIsDir  = rsIsDir(1).IsDir;    
    parentDirID = rsIsDir(1).ParentDirID;
    strPathRoot = findreplace(rsIsDir(1).Directory,'\\','\');
    blnFullDir = 0;
    
    if blnIsDir == 1
        strFullPath = ['\' rsIsDir(1).Name '\'];
    elseif blnReturnDir == 0
        strFullPath = ['\' rsIsDir(1).Name];
    else
        strFullPath = '\';
    end
    
    while parentDirID > 0
        sql_GetParentDir = ['select Name, ParentDirID from data where ' ...
                            'DataID = ' num2str(parentDirID) ' and IsDir = 1'];
        rsGetParentDir   = mksqlite(sql_GetParentDir);
        strFullPath      = ['\' rsGetParentDir(1).Name strFullPath];
        parentDirID      = rsGetParentDir(1).ParentDirID;
        clear rsGetParentDir        
    end
    
    strFullPath = [strPathRoot strFullPath];
    clear rsIsDir
    
    
% --- Executes on button press in load_listener.
function load_listener_Callback(hObject, eventdata, handles)
% hObject    handle to load_listener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    img_loader;



% --- Executes on button press in load_picker.
function load_browser_Callback(hObject, eventdata, handles)
% hObject    handle to load_picker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    dbase_browser;
    
    
% --- Executes on button press in load_picker.
function load_picker_Callback(hObject, eventdata, handles)
% hObject    handle to load_picker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    img_browser;
