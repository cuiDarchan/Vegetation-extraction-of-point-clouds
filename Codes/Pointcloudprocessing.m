function varargout = Pointcloudprocessing(varargin)
% POINTCLOUDPROCESSING MATLAB code for Pointcloudprocessing.fig
%      POINTCLOUDPROCESSING, by itself, creates a new POINTCLOUDPROCESSING or raises the existing
%      singleton*.
%
%      H = POINTCLOUDPROCESSING returns the handle to a new POINTCLOUDPROCESSING or the handle to
%      the existing singleton*.
%
%      POINTCLOUDPROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POINTCLOUDPROCESSING.M with the given input arguments.
%
%      POINTCLOUDPROCESSING('Property','Value',...) creates a new POINTCLOUDPROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Pointcloudprocessing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Pointcloudprocessing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Pointcloudprocessing

% Last Modified by GUIDE v2.5 16-May-2018 09:33:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Pointcloudprocessing_OpeningFcn, ...
                   'gui_OutputFcn',  @Pointcloudprocessing_OutputFcn, ...
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


% --- Executes just before Pointcloudprocessing is made visible.
function Pointcloudprocessing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Pointcloudprocessing (see VARARGIN)

% Choose default command line output for Pointcloudprocessing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Pointcloudprocessing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Pointcloudprocessing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path as text
%        str2double(get(hObject,'String')) returns contents of edit_path as a double


% --- Executes during object creation, after setting all properties.
function edit_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openfile.
function [filename,pathname,PointMatrix]=openfile_Callback(hObject, eventdata,handles)
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname]=uigetfile('*.txt','请打开txt点云文件');
fullname=strcat(pathname,filename);
set(handles.edit_path,'string',fullname);
PointMatrix=load(fullname);
handles.PointMatrix=PointMatrix;
guidata(hObject,handles);           %注意与上一行两行一起写

% --- Executes during object creation, after setting all properties.
function edit_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in producetxt.
function producetxt_Callback(hObject, eventdata, handles)
% hObject    handle to producetxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in producelasqz.
function producelasqz_Callback(hObject, eventdata, handles)
% hObject    handle to producelasqz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pd=1;
if  strcmp (get(handles.edit_path,'string'),'txt点云文件路径')
    msgbox('请先选择需要处理的txt点云文件', '提示');
elseif  strcmp(get(handles.editcell,'string'),'元胞尺寸值,一般在2-4之间')
    msgbox('请先填写元胞尺寸', '提示');    
else    
    while pd   
    ave=str2double(get(handles.editcell,'string'));    
    if ave<0.5||ave>5||isnan(ave)==1
       msgbox('请改写正确元胞尺寸', '提示');
       break;
    end
    %存储文件路径
    [SaveFileName,SavePathName,~]=uiputfile({'*.las','经处理后的点云数据(*.las)'},'输入存储路径');
    SavefullName=strcat(SavePathName,SaveFileName);
    PointMatrix=handles.PointMatrix;
    %去噪处理
    Bb=lasdata('Reference.las');
    newlandcell=ult_deletenoise(ave,PointMatrix);
    C=write_qztxt(newlandcell);
    [Bb,C]=deletezeros(C,Bb);
    write_las(Bb, SavefullName, Bb.header.version_major, Bb.header.version_minor, Bb.header.point_data_format);
    msgbox('恭喜点云去噪成功', '提示');   
    pd=0;
    end
end


% --- Executes on button press in carpoint.
function carpoint_Callback(hObject, eventdata, handles)
% hObject    handle to carpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of carpoint

% --- Executes on button press in quzao.
function quzao_Callback(hObject, eventdata, handles)
% hObject    handle to quzao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of quzao



function editcell_Callback(hObject, eventdata, handles)
% hObject    handle to editcell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editcell as text
%        str2double(get(hObject,'String')) returns contents of editcell as a double


% --- Executes during object creation, after setting all properties.
function editcell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editcell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over editcell.
function editcell_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to editcell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', '', 'Enable', 'on');
uicontrol(hObject);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over treepoints.
function treepoints_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to treepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over buildpoints.
function buildpoints_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to buildpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over carpoints.
function carpoints_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to carpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over groundpoints.
function groundpoints_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to groundpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if get(handles.groundpoints,'value')==0
%     set(handles.carpoints,'value',0);
%     set(handles.buildpoints,'value',0);
%     set(handles.groundpoints,'value',1);
%     set(handles.treepoints,'value',0);
% else if get(handles.groundpoints,'value')==1
%         set(handles.carpoints,'value',0);
%         set(handles.buildpoints,'value',0);
%         set(handles.groundpoints,'value',0);
%         set(handles.treepoints,'value',0);
%     end
% end

% --- Executes on button press in radiobutton10.
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10

function editdelth_Callback(hObject, eventdata, handles)
% hObject    handle to editdelth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editdelth as text
%        str2double(get(hObject,'String')) returns contents of editdelth as a double


% --- Executes during object creation, after setting all properties.
function editdelth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editdelth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editptsm_Callback(hObject, eventdata, handles)
% hObject    handle to editptsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editptsm as text
%        str2double(get(hObject,'String')) returns contents of editptsm as a double


% --- Executes during object creation, after setting all properties.
function editptsm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editptsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in producelasground.
function producelasground_Callback(hObject, eventdata, handles)
% hObject    handle to producelasground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pd=1;
if  strcmp (get(handles.editptsm,'string'),'以真实点云密度值为准，如0.902')
    msgbox('请先正确填写点云密度值', '提示');
elseif  strcmp (get(handles.editdelth,'string'),'高度判别阈值参数，一般设置为1-3')
    msgbox('请先填写正确的高度阈值', '提示');
%地面
else    
    while pd
    str1=get(handles.editptsm,'string');
    a=str2double(str1);
    if a<=0||a>30||isnan(a)==1
       msgbox('请改写正确的点云密度值', '提示');
       break;
    end
    str2=get(handles.editdelth,'string');
    b=str2double(str2);
    if b<=0||a>5||isnan(b)==1
       msgbox('请改写正确的高度阈值', '提示');
       break;
    end
    %存储文件路径
    [SaveFileName,SavePathName,~]=uiputfile({'*.las','经处理后的点云数据(*.las)'},'输入存储路径');
    SavefullName=strcat(SavePathName,SaveFileName);
    PointMatrix=handles.PointMatrix;
    Bb=lasdata('Reference.las');                 
    [groundpoints,~]=Groundpoints_classification(a,PointMatrix,b);
    [Bb]=Matrixproperty(groundpoints,Bb);                       %改写头文件
    write_las(Bb,SavefullName , Bb.header.version_major, Bb.header.version_minor, Bb.header.point_data_format);
    msgbox('恭喜提取地面点云成功', '提示');
    pd=0;
    end
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over editptsm.
function editptsm_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to editptsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', '', 'Enable', 'on');
uicontrol(hObject);
handles.X=X;
guidata(hObject,handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over editdelth.
function editdelth_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to editdelth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', '', 'Enable', 'on');
uicontrol(hObject);
